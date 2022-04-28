## POP-Maker Build

> Note: These are the instructions for building the POP-Maker application and its disk images.  
>  
> If you want to rebuild the Prince of Persia game code, visit the [`merlin32`](../merlin32) directory.  Performing a `make install` from the Merlin32 directory will update the binaries in `pop-maker/obj`.


### Requirements
* [Merlin32 Assembler](http://www.brutaldeluxe.fr/products/crossdevtools/merlin/)
* [Cadius disk image manager](http://www.brutaldeluxe.fr/products/crossdevtools/cadius/index.html)
* Unix-like development environment (for make, etc).

### Steps
1. Install Merlin32 and Cadius to your system.
2. Edit `makefile` and set the paths to Merlin32 and Cadius
3. Run `make`

Example:

    cd pop-maker
    make cleanall
    make all

This will produce one 3.5" disk image and three 5.25" disk images:

    popmaker35.po
    popmaker525.1.po
    popmaker525.2.po
    popmaker525.3.po
    
