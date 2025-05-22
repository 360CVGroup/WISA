#!/bin/bash
MODEL_TYPE="wanx2_1"  # "cogvideox" or "wanx2_1"
GEN_TYPE="wisa" # "baseline", "lora" or "wisa"


if [[ "$MODEL_TYPE" != "cogvideox" && "$MODEL_TYPE" != "wanx2_1" ]]; then
    echo "Error: MODEL_TYPE must be 'cogvideox' or 'wanx2_1'"
    exit 1
fi

if [[ "$GEN_TYPE" != "baseline" && "$GEN_TYPE" != "lora" && "$GEN_TYPE" != "wisa" ]]; then
    echo "Error: GEN_TYPE must be 'baseline', 'lora' or 'wisa'"
    exit 1
fi

# if PROMPT_PATH is correct path, PROMPT will not be adopt
PROMPT="A bowl of clear water sits in the center of a freezer. As the temperature gradually drops, tiny ice crystals begin to form on the surface, resembling a thin layer of frost. The crystals spread rapidly, connecting to create a delicate solid ice film. Over time, the film thickens and eventually covers the entire surface, while the water beneath slowly freezes. Finally, the entire bowl of water solidifies into a transparent block of ice, reflecting the faint light of the freezer and illustrating the transformation from liquid to solid."

# for WISA, PROMPT_PATH will be requried
PROMPT_PATH="./assets/example.json"
OUTPUT_FILE="outputs_test"

if [[ "$MODEL_TYPE" == "wanx2_1" ]]; then
    MODEL_PATH="./pretrain_models/wan2.1_14B_diffusers_notebook"
    NUM_FRAMES=81
    FPS=16
    SEED=42
    GUIDANCE_SCALE=6.0
elif [[ "$MODEL_TYPE" == "cogvideox" ]]; then
    MODEL_PATH="./pretrain_models/CogvideoX1.5-5B-notebook"
    NUM_FRAMES=49
    FPS=16
    SEED=42
    GUIDANCE_SCALE=6.0
fi


CMD="python ./tests/test_wisa_inference.py \
    --prompt \"$PROMPT\" \
    --prompt_path \"$PROMPT_PATH\" \
    --output_file \"$OUTPUT_FILE\" \
    --model_path \"$MODEL_PATH\" \
    --num_frames $NUM_FRAMES \
    --model_type \"$MODEL_TYPE\" \
    --generate_type \"$GEN_TYPE\" \
    --fps $FPS \
    --guidance_scale $GUIDANCE_SCALE \
    --seed $SEED"


if [[ "$GEN_TYPE" == "wisa" || "$GEN_TYPE" == "lora" ]]; then
    LORA_PATH="./pretrain_models/WISA/wan2.1-t2v-14b-480p-wisa"
    LORA_RANK=128
    LORA_ALPHA=16
    PHYS_GUIDANCE_SCALE=3.0
    CMD="$CMD --lora_path \"$LORA_PATH\" --phys_guidance_scale $PHYS_GUIDANCE_SCALE --lora_rank $LORA_RANK --lora_alpha $LORA_ALPHA"
fi

echo "Executing: $CMD"
eval $CMD
