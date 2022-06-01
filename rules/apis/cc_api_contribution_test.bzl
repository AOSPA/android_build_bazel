"""Copyright (C) 2022 The Android Open Source Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(":cc_api_contribution.bzl", "CcApiContributionInfo", "CcApiHeaderInfo", "cc_api_contribution", "cc_api_headers")

def _empty_include_dir_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    asserts.equals(env, paths.dirname(ctx.build_file_path), target_under_test[CcApiHeaderInfo].root)
    return analysistest.end(env)

empty_include_dir_test = analysistest.make(_empty_include_dir_test_impl)

def _empty_include_dir_test():
    test_name = "empty_include_dir_test"
    subject_name = test_name + "_subject"
    cc_api_headers(
        name = subject_name,
        hdrs = ["hdr.h"],
        tags = ["manual"],
    )
    empty_include_dir_test(
        name = test_name,
        target_under_test = subject_name,
    )
    return test_name

def _nonempty_include_dir_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    expected_root = paths.join(paths.dirname(ctx.build_file_path), ctx.attr.expected_include_dir)
    asserts.equals(env, expected_root, target_under_test[CcApiHeaderInfo].root)
    return analysistest.end(env)

nonempty_include_dir_test = analysistest.make(
    impl = _nonempty_include_dir_test_impl,
    attrs = {
        "expected_include_dir": attr.string(),
    },
)

def _nonempty_include_dir_test():
    test_name = "nonempty_include_dir_test"
    subject_name = test_name + "_subject"
    include_dir = "my/include"
    cc_api_headers(
        name = subject_name,
        include_dir = include_dir,
        hdrs = ["my/include/hdr.h"],
        tags = ["manual"],
    )
    nonempty_include_dir_test(
        name = test_name,
        target_under_test = subject_name,
        expected_include_dir = include_dir,
    )
    return test_name

def _api_path_is_relative_to_workspace_root_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    expected_path = paths.join(paths.dirname(ctx.build_file_path), ctx.attr.expected_symbolfile)
    asserts.equals(env, expected_path, target_under_test[CcApiContributionInfo].api)
    return analysistest.end(env)

api_path_is_relative_to_workspace_root_test = analysistest.make(
    impl = _api_path_is_relative_to_workspace_root_test_impl,
    attrs = {
        "expected_symbolfile": attr.string(),
    },
)

def _api_path_is_relative_to_workspace_root_test():
    test_name = "api_path_is_relative_workspace_root"
    subject_name = test_name + "_subject"
    symbolfile = "libfoo.map.txt"
    cc_api_contribution(
        name = subject_name,
        api = symbolfile,
        tags = ["manual"],
    )
    api_path_is_relative_to_workspace_root_test(
        name = test_name,
        target_under_test = subject_name,
        expected_symbolfile = symbolfile,
    )
    return test_name

def _empty_library_name_gets_label_name_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    asserts.equals(env, target_under_test.label.name, target_under_test[CcApiContributionInfo].name)
    return analysistest.end(env)

empty_library_name_gets_label_name_test = analysistest.make(_empty_library_name_gets_label_name_impl)

def _empty_library_name_gets_label_name_test():
    test_name = "empty_library_name_gets_label_name"
    subject_name = test_name + "_subject"
    cc_api_contribution(
        name = subject_name,
        api = ":libfoo.map.txt",
        tags = ["manual"],
    )
    empty_library_name_gets_label_name_test(
        name = test_name,
        target_under_test = subject_name,
    )
    return test_name

def _nonempty_library_name_preferred_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    asserts.equals(env, ctx.attr.expected_library_name, target_under_test[CcApiContributionInfo].name)
    return analysistest.end(env)

nonempty_library_name_preferred_test = analysistest.make(
    impl = _nonempty_library_name_preferred_impl,
    attrs = {
        "expected_library_name": attr.string(),
    },
)

def _nonempty_library_name_preferred_test():
    test_name = "nonempty_library_name_preferred_test"
    subject_name = test_name + "_subject"
    library_name = "mylibrary"
    cc_api_contribution(
        name = subject_name,
        library_name = library_name,
        api = ":libfoo.map.txt",
        tags = ["manual"],
    )
    nonempty_library_name_preferred_test(
        name = test_name,
        target_under_test = subject_name,
        expected_library_name = library_name,
    )
    return test_name

def cc_api_test_suite(name):
    native.test_suite(
        name = name,
        tests = [
            _empty_include_dir_test(),
            _nonempty_include_dir_test(),
            _api_path_is_relative_to_workspace_root_test(),
            _empty_library_name_gets_label_name_test(),
            _nonempty_library_name_preferred_test(),
        ],
    )
