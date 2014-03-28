#
# Makefile by appleboy <appleboy.tw AT gmail.com>
#
obj-m       += kset-example.o
KVERSION := $(shell uname -r)
 
all:
    $(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
 
clean:
    $(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) clean