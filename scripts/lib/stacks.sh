#!/usr/bin/env bash

sync_stack_files() {
    local source_dir="$1"
    local target_dir="$2"
    local source_file relative_path target_file

    while IFS= read -r -d '' source_file; do
        relative_path="${source_file#"$source_dir"/}"
        target_file="$target_dir/$relative_path"
        mkdir -p "$(dirname "$target_file")"
        cp "$source_file" "$target_file"
    done < <(find "$source_dir" -path "$source_dir/hooks" -prune -o -type f ! -name '*.example' -print0)
}

run_stack_hook() {
    local source_dir="$1"
    local target_dir="$2"
    local hook_file="$source_dir/hooks/after-deploy.sh"

    if [[ -f "$hook_file" ]]; then
        bash "$hook_file" "$target_dir"
    fi
}

deploy_stack() {
    local stack_name="$1"
    local source_dir="$SERVER_DIR/stacks/$stack_name"
    local target_dir="$STACKS_DIR/$stack_name"

    if [[ ! -f "$source_dir/compose.yaml" ]]; then
        fail "Stack $stack_name has no compose.yaml in $source_dir"
    fi

    log_info "Deploying $stack_name"
    mkdir -p "$target_dir"
    sync_stack_files "$source_dir" "$target_dir"
    create_missing_templates "$source_dir" "$target_dir"
    build_stack_env "$source_dir" "$target_dir"
    start_stack "$target_dir"
    run_stack_hook "$source_dir" "$target_dir"
}

deploy_all_stacks() {
    local stack_names stack_name

    if [[ "$(realpath -m "$STACKS_DIR")" == "$(realpath -m "$SERVER_DIR/stacks")" ]]; then
        fail "STACKS_DIR must be outside the repository"
    fi

    mkdir -p "$STACKS_DIR"
    read -ra stack_names <<< "$STACKS"

    for stack_name in "${stack_names[@]}"; do
        deploy_stack "$stack_name"
    done
}
