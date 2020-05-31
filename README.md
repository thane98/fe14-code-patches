# fe14-code-patches
Misc. code patches that add new features to FE14.

To apply a patch, you need a working copy of armips. Copy your *code.bin* to a working directory, rename it to *codebase.bin*, run armips, and pass in the patch you want to apply.

For example, to apply the butler patch you would run: *armips butler.s*

If there are no issues, armips will produce a code.bin file with the patches applied.

**Note that all patches target NA special edition. They will not work on other versions of the game.**

## Patches
### butler.s
Template file for adding new My Castle assistants. The example adds Scarlet, Saizo, Kagero, and Anna.

### motherportraits.s
Adds the ability to load custom portraits for child characters depending on their mother.

### notmycastle.s
Removes virtually all customization features from My Castle. No butlers / castle edit menu, no bookshelf or crystal ball, and no changing menus on the bottom screen.

Probably not useful on its own.
