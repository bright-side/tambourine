#!/usr/bin/env bats

load lib

setup() {
    user_error_message="user error message"
}

@test "Error message has not been specified, the path specified to the directory is absolute" {
    run check_dir "$BATS_TEST_DIRNAME/nonexistent_dir"

    [[ "$output" == "Internal error: the directory \"$BATS_TEST_DIRNAME/nonexistent_dir\" does not exist!" ]]
}

@test "Error message has not been specified, the path specified to the directory is local" {
    run check_dir "nonexistent_dir"

    [[ "$output" == "Internal error: the directory \"`pwd`/nonexistent_dir\" does not exist!" ]]
}

@test "Error message has been specified" {
    run check_dir "nonexistent_dir" "$user_error_message"

    [[ "$output" == "$user_error_message" ]]
}

@test "The directory doesn't exist" {
    run check_dir "$BATS_TEST_DIRNAME/nonexistent_dir"

    [ "$status" -eq 1 ]
}

@test "The directory exists" {
    run check_dir "$BATS_TEST_DIRNAME/check_dir"

    [ "$status" -eq 0 ]
}

@test "The directory is a symbolic link pointing at nonexistent directory" {
    run check_dir "$BATS_TEST_DIRNAME/check_nonexistent_dir.symlink"

    [ "$status" -eq 1 ]
}

@test "The directory is a symbolic link pointing at existent directory" {
    run check_dir "$BATS_TEST_DIRNAME/check_existent_dir.symlink"

    [ "$status" -eq 0 ]
}

