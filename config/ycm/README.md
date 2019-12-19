### reference

- <https://bastian.rieck.ru/blog/posts/2015/ycm_cmake/>

### usage

1. add the following code to CMakeLists.txt

    ```cmake
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

    add_custom_target(
        copy_compile_commands ALL
        COMMAND
            ${CMAKE_COMMAND} -E copy_if_different
            ${PROJECT_BINARY_DIR}/compile_commands.json
            ${PROJECT_SOURCE_DIR}/compile_commands.json
        COMMENT "copy compile_commands.json to ${PROJECT_SOURCE_DIR} if different."
        )
    ```

    or save the code to YCMConfig.cmake and add "include(YCMConfig)" to CMakeLists.txt file.

2. copy cmake/.ycm_extra_conf.py to your project folder

3. run cmake to configure your project

4. edit source code with vim and youcompleteme can use the generated compile_commands.json now.
