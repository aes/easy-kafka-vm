import datetime


class Timing:
    def __init__(self):
        self.r = {}

    def __enter__(self):
        self.r["start"] = datetime.datetime.now()
        return self.r

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.r["end"] = datetime.datetime.now()


timing = Timing()

def run_with_timing(module, **kw):
    with Timing() as r:
        r["rc"], r["stdout"], r["stderr"] = module.run_command(**kw)
    return r
