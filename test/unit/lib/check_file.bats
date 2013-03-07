#!/usr/bin/env bats

load lib

setup() {
    user_error_message="user error message"
}

@test "Error message has not been specified, the path specified to the directory is absolute" {
    run check_file "$BATS_TEST_DIRNAME/nonexistent_file"

    [[ "$output" == "Internal error: the file \"$BATS_TEST_DIRNAME/nonexistent_file\" does not exist!" ]]
}

@test "Error message has not been specified, the path specified to the directory is local" {
    run check_file "nonexistent_file"

    [[ "$output" == "Internal error: the file \"`pwd`/nonexistent_file\" does not exist!" ]]
}

@test "Error message has been specified" {
    run check_file "nonexistent_file" "$user_error_message"

    [[ "$output" == "$user_error_message" ]]
}

@test "The file doesn't exist" {
    run check_file "nonexistent_file" "$user_error_message"

    [ "$status" -eq 1 ]
}

@test "The file exist" {
    run check_file "$BATS_TEST_DIRNAME/check_file/existent_file"

    [ "$status" -eq 0 ]
}

@test "The file is a symbolic link pointing at nonexistent file" {
    run check_file "$BATS_TEST_DIRNAME/check_nonexistent_file.symlink"

    [ "$status" -eq 1 ]
}

@test "The file is a symbolic link pointing at existent file" {
    run check_file "$BATS_TEST_DIRNAME/check_existent_file.symlink"

    [ "$status" -eq 0 ]
}

