
# Copyright (c) Meta Platforms, Inc. and affiliates.

set -euo pipefail

stop_runpod_on_done() {
    if [[ "${STOP_RUNPOD_ON_DONE:-0}" != "1" ]]; then
        return
    fi

    if [[ -z "${RUNPOD_POD_ID:-}" ]]; then
        echo "STOP_RUNPOD_ON_DONE=1 but RUNPOD_POD_ID is not set; leaving pod running."
        return
    fi

    echo "All ablations completed successfully. Stopping RunPod pod ${RUNPOD_POD_ID}..."

    if command -v runpodctl >/dev/null 2>&1; then
        runpodctl pod stop "${RUNPOD_POD_ID}"
        return
    fi

    if [[ -z "${RUNPOD_API_KEY:-}" ]]; then
        echo "runpodctl not found and RUNPOD_API_KEY is not set; leaving pod running."
        return
    fi

    curl --fail --request POST \
        --url "https://rest.runpod.io/v1/pods/${RUNPOD_POD_ID}/stop" \
        --header "Authorization: Bearer ${RUNPOD_API_KEY}"
}

dataset_name=Beauty

# # Dense (ID)
python run.py \
    dataset=amazon \
    dataset.name=$dataset_name \
    seed=42 \
    device_id=0 \
    method=setting \
    test_method=liger \
    method.sid_loss_weight=0 \
    method.use_id="item_id" \
    method.embedding_head_dict.embed_target="ground_truth+item_id" \
    method.embedding_head_dict.embed_proj_type="linear" \
    method.embedding_head_dict.use_new_init=True \
    experiment_id="ablation_dense_id"



# # Dense (SID)
python run.py \
    dataset=amazon \
    dataset.name=$dataset_name \
    seed=42 \
    device_id=0 \
    method=setting \
    test_method=liger \
    method.sid_loss_weight=0 \
    experiment_id="ablation_dense_sid"


# liger
python run.py \
    dataset=amazon \
    dataset.name=$dataset_name \
    seed=42 \
    device_id=0 \
    method=setting \
    test_method=liger \
    experiment_id="ablation_liger" 


# tiger(T)
python run.py \
    dataset=amazon \
    dataset.name=$dataset_name \
    seed=42 \
    device_id=0 \
    method=setting \
    test_method=liger \
    method.flag_use_output_embedding=False \
    method.embedding_loss_weight=0 \
    experiment_id="ablation_tiger_text"


# tiger
python run.py \
    dataset=amazon \
    dataset.name=$dataset_name \
    seed=42 \
    device_id=0 \
    method=base \
    test_method=tiger \
    experiment_id="ablation_tiger"

stop_runpod_on_done
