set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_custom_target(
    copy_compile_commands ALL
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/compile_commands.json
        ${PROJECT_SOURCE_DIR}/compile_commands.json
    COMMENT "copy compile_commands.json to ${PROJECT_SOURCE_DIR} if different."
    )

