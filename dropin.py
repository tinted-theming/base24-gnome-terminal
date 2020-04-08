#!/usr/bin/env python3
import os
import sys
import shutil
import asyncio

GIT_CLONE_PATH = "base24-builder-python-portable"

# clone base24-builder-python-portable
async def git_clone():
	proc_env = os.environ.copy()
	proc_env["GIT_TERMINAL_PROMPT"] = "0"

	git_proc = await asyncio.create_subprocess_exec(
		"git", "clone", "https://github.com/Base24/base24-builder-python-portable", GIT_CLONE_PATH, stderr=asyncio.subprocess.PIPE, env=proc_env
	)
	_stdout, _stderr = await git_proc.communicate()
	if git_proc.returncode != 0:
		# remove created directory if it's empty
		try:
			os.rmdir(GIT_CLONE_PATH)
		except OSError:
			pass

# copy base24_builder/* and base24
def copy_dropin():
	builder_dir = os.path.join(os.getcwd(), GIT_CLONE_PATH, "base24_builder")
	os.makedirs(os.path.join(os.getcwd(), "base24_builder"), exist_ok=True)
	for item in os.listdir(builder_dir):
		shutil.copy2(os.path.join(builder_dir, item), os.path.join(os.getcwd(),"base24_builder", item))
	shutil.copy2(os.path.join(os.getcwd(), GIT_CLONE_PATH, "base24.py"), os.path.join(os.getcwd(), "base24.py"))

asyncio.get_event_loop().run_until_complete(git_clone())
copy_dropin()
