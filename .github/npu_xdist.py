"""Shared pytest plugin for Ascend NPU CI.

Load it with ``pytest -p npu_xdist`` after adding this directory to
``PYTHONPATH``. The job must set ``ASCEND_RT_VISIBLE_DEVICES`` to ``0,1,...``
first: each xdist worker then keeps only its own device.

Also re-exports ``triton_key`` for torch_npu Inductor on Triton 3.6, and drops
a leftover default process group so the next test in a long-lived worker does
not fail with "trying to initialize the default process group twice".
"""

import os

import pytest

_worker = os.environ.get("PYTEST_XDIST_WORKER")
if _worker and _worker.startswith("gw"):
    os.environ["ASCEND_RT_VISIBLE_DEVICES"] = _worker[2:]


def _export_triton_key():
    try:
        import triton.compiler.compiler as compiler

        if not hasattr(compiler, "triton_key"):
            from triton.runtime.cache import triton_key

            compiler.triton_key = triton_key
    except Exception:
        return


def _destroy_default_process_group():
    try:
        import torch.distributed as dist

        if dist.is_available() and dist.is_initialized():
            dist.destroy_process_group()
    except Exception:
        return


_export_triton_key()


@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_setup(item):
    _destroy_default_process_group()
    yield


@pytest.hookimpl(hookwrapper=True, trylast=True)
def pytest_runtest_teardown(item):
    yield
    _destroy_default_process_group()
