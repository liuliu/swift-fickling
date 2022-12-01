# Swift Fickling

This is inspired by work from Trail of Bits on [Fickling](https://github.com/trailofbits/fickling). Many Stable Diffusion models are published in pickle format. Pickle format has been traditionally tied to a Python installation. This limitation exists also because pickle has the liberty to call into any Python function they want and allows you to override certain part of serialization (i.e. using external files and serialize only so-called `persistent_id`).

As such, there are also security implications on deserializing untrusted pickle format per <https://blog.trailofbits.com/2021/03/15/never-a-dill-moment-exploiting-machine-learning-pickle-files/>.

`swift-fickling` while taking name from [Fickling](https://github.com/trailofbits/fickling) doesn't do static analyze or decompilation yet. It simply read the pickle opcodes, execute them on a Swift implemented pickle VM within the context you provided. Thus, we side-stepped the security implications by silencing outside function calls unless you explicitly providing them.

This turns out to be just enough to deserialize PyTorch based pickle files without Python installation.

## Limitations

The current implementation would be wrong for some pickle files. The main cause is how Python and Swift treat dictionaries and arrays (lists) differently.

In Swift, dictionaries and arrays are value types. If you mutate a dictionary, it won't affects objects previously holding that dictionary. Pickle VM follows Harvard architecture. If you mutate a dictionary from the stack, but the same dictionary was also held by the lookup memory, they will diverge. Luckily, this doesn't happen for pickle files I care about because most pickle files only ever call `SETITEMS` once on a dictionary to build them.

It is possible to solve this issue by wrapping dictionaries and arrays into a class type, I need examples of such pickle file to start this work. It may also requires me to introduce similar things like `PythonObject` in `PythonKit` to wrap around some usages. We are not there yet.
