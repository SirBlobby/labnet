#!/usr/bin/env bash

env_line_key() {
    if [[ "$1" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

env_file_has_key() {
    [[ -f "$1" ]] && grep -q "^$2=" "$1"
}

render_template_line() {
    local line="$1"
    local key placeholder

    while [[ "$line" == *__GENERATE_SECRET__* ]]; do
        line="${line/__GENERATE_SECRET__/"$(generate_secret)"}"
    done
    while [[ "$line" == *__GENERATE_BASE64_KEY__* ]]; do
        line="${line/__GENERATE_BASE64_KEY__/"$(generate_base64_key)"}"
    done
    for key in "${SERVER_ENV_KEYS[@]}"; do
        placeholder="{{$key}}"
        line="${line//"$placeholder"/"${!key}"}"
    done

    printf '%s\n' "$line"
}

render_template_file() {
    local template_file="$1"
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        render_template_line "$line"
    done < "$template_file"
}

create_missing_templates() {
    local source_dir="$1"
    local target_dir="$2"
    local template_file relative_path target_file

    while IFS= read -r -d '' template_file; do
        if [[ "$(basename "$template_file")" == ".env.example" ]]; then
            continue
        fi

        relative_path="${template_file#"$source_dir"/}"
        target_file="$target_dir/${relative_path%.example}"

        if [[ -e "$target_file" ]]; then
            continue
        fi

        mkdir -p "$(dirname "$target_file")"
        render_template_file "$template_file" > "$target_file"
        chmod 600 "$target_file"
        log_info "Created $target_file"
    done < <(find "$source_dir" -path "$source_dir/hooks" -prune -o -type f -name '*.example' -print0)
}

build_stack_env() {
    local source_dir="$1"
    local target_dir="$2"
    local example_file="$source_dir/.env.example"
    local target_file="$target_dir/.env"
    local new_file line key

    new_file="$(mktemp)"
    grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$SERVER_ENV_FILE" > "$new_file" || true

    if [[ -f "$example_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            key="$(env_line_key "$line")" || continue
            if env_file_has_key "$new_file" "$key"; then
                continue
            fi
            if env_file_has_key "$target_file" "$key"; then
                grep -m1 "^$key=" "$target_file" >> "$new_file"
            else
                render_template_line "$line" >> "$new_file"
            fi
        done < "$example_file"
    fi

    if [[ -f "$target_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            key="$(env_line_key "$line")" || continue
            if ! env_file_has_key "$new_file" "$key"; then
                printf '%s\n' "$line" >> "$new_file"
            fi
        done < "$target_file"
    fi

    install -m 600 "$new_file" "$target_file"
    rm -f "$new_file"
}
