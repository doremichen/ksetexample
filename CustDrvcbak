/**
* This is cust driver sample code
*/

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/wait.h>
#include <linux/interrupt.h>
#include <linux/input.h>
#include <linux/kobject.h>
#include <linux/slab.h>
#include <cust_eint.h> 
#include <mach/mt_gpio.h>

#define __DEBUG__

#ifdef __DEBUG__
    #define DEBUGI(format, ...) printk(KERN_INFO "[CustDev]"format"\n",##__VA_ARGS__)
    #define DEBUGE(format, ...) printk(KERN_ERR "[CustDev]"format"\n",##__VA_ARGS__)
#else
    #define DEBUGI(format, ...)
    #define DEBUGE(format, ...)
#endif


//interrupt api for mtk platform
extern void mt65xx_eint_unmask(unsigned int line);
extern void mt65xx_eint_mask(unsigned int line);
extern void mt65xx_eint_set_polarity(unsigned int eint_num, unsigned int pol);
extern void mt65xx_eint_set_hw_debounce(unsigned int eint_num, unsigned int ms);
extern unsigned int mt65xx_eint_set_sens(unsigned int eint_num, unsigned int sens);
extern void mt65xx_eint_registration(unsigned int eint_num, unsigned int is_deb_en,
			                         unsigned int pol, void (EINT_FUNC_PTR) (void), 
			                         unsigned int is_auto_umask);
//interruot handler function									 
//typedef void(*eint_handler)(void);								 

/*
* 
*/
struct cust_device {
    struct kobject kobj;
	int ref;
};

#define to_custDev_device(x) container_of(x, struct cust_device, kobj)

static struct cust_device * cust_dev = NULL;
static struct kset * cust_dev_kset = NULL;

/*
* This is interrupt handler function
* example:
*   mt65xx_eint_registration(CUST_EINT_COMMS_WAKEUP_NUM, CUST_EINT_COMMS_WAKEUP_DEBOUNCE_EN,
*  	                         CUST_EINT_COMMS_WAKEUP_POLARITY, cust_dev_wakeup_eint_handler, 0);
*/									 
//static void 
//cust_dev_wakeup_eint_handler(void)
//{
//    DEBUGI("[%s]: COMMS_WAKEUP EINT TRIGGER!\n", __FUNCTION__);
//	mt65xx_eint_unmask(CUST_EINT_COMMS_WAKEUP_NUM);
//}									 

/*
* 
*/
struct custDev_sysfs_entry {
	struct attribute attr;
	ssize_t (*show)(struct cust_device *, char *);
	ssize_t (*store)(struct cust_device *, const char *, size_t);
};

#define to_custDev_sysfs_entry(x) container_of(x, struct custDev_sysfs_entry, attr)


/*
* 
*/
static ssize_t 
cust_dev_show(struct cust_device *di, char *buf)
{
    DEBUGI("[%s]: enter\n", __FUNCTION__);
	return sprintf(buf, "%d\n", di->ref);
}

/*
* 
*/
static ssize_t 
cust_dev_store(struct cust_device *di, const char *buf, size_t count)
{
	int var;
	DEBUGI("[%s]: enter\n", __FUNCTION__);
    sscanf(buf, "%du", &var);
	di->ref = var;
	return count;
}

//static ssize_t 
//me_show(struct nugen_device *di, char *buf)
//{
//	return sprintf(buf, "%d\n", di->ref);
//}
//
//static ssize_t 
//me_store(struct nugen_device *di, const char *buf, size_t count)
//{
//	int var, ret;
//	char *connected[2] = { "USB_STATE=CONNECTED", NULL };
//	
//    sscanf(buf, "%du", &var);
//	di->ref = var;
//	
//	if (var == 5)
//	{
//	    if ( (ret = kobject_uevent_env(&di->kobj, KOBJ_CHANGE, connected)) != 0)
//		     printk(KERN_INFO " Nugen: err= %d\n\n", ret); 
//        else
//             printk(KERN_INFO " Nugen: ret= %d\n",ret);		
//	}
//	return count;
//}

static struct custDev_sysfs_entry cust_dev_attr =
	__ATTR(ref, 0666, cust_dev_show, cust_dev_store);


static ssize_t
custDev_show(struct kobject *kobj, struct attribute *attr, char *buf)
{
    struct custDev_sysfs_entry* entry = to_custDev_sysfs_entry(attr);
	struct cust_device* di         = to_custDev_device(kobj);
	DEBUGI("[%s]: enter\n", __FUNCTION__);
	
	if (!entry->show)
	    return -EIO;
		
	return entry->show(di, buf);
}

static ssize_t
custDev_store(struct kobject *kobj, struct attribute *attr, const char *buf, size_t count)
{
    struct custDev_sysfs_entry* entry = to_custDev_sysfs_entry(attr);
	struct cust_device* di         = to_custDev_device(kobj);
    DEBUGI("[%s]: enter\n", __FUNCTION__);

	if (!entry->store)
		return -EIO;

	return entry->store(di, buf, count);
}

static const struct sysfs_ops custDev_sysfs_ops = {
	.show = custDev_show,
	.store = custDev_store,
};

static struct attribute *cust_dev_attrs[] = {
	&cust_dev_attr.attr,
	NULL,
};

static struct kobj_type cust_dev_ktype = {
	.sysfs_ops = &custDev_sysfs_ops,
	.default_attrs = cust_dev_attrs,
};

/*
* 
*/
static struct cust_device*
create_custDev_dev(const char *name, struct kobj_type *ktype)
{
	struct cust_device *nd;
	int retval;
    DEBUGI("[%s]: enter\n", __FUNCTION__);

	nd = kzalloc(sizeof(struct cust_device), GFP_KERNEL);
	if (!nd)
		return NULL;

	nd->kobj.kset = cust_dev_kset;

	retval = kobject_init_and_add(&nd->kobj, ktype, NULL, "%s", name);
	if (retval) {
		kobject_put(&nd->kobj);
		return NULL;
	}

	//kobject_uevent(&nd->kobj, KOBJ_ADD);
	return nd;
}

static void
destroy_custDev_dev(struct cust_device *nd)
{
    DEBUGI("[%s]: enter\n", __FUNCTION__);
	kobject_del(&nd->kobj);
	kfree(nd);
}

/*
* 
*/
static int 
custDev_sysfs_init(void)
{
	int ret = 0;
    cust_dev_kset = kset_create_and_add("cust_kset", NULL, NULL);
	DEBUGI("[%s]: enter\n", __FUNCTION__);
	
	if (!cust_dev_kset)
	{
	   DEBUGE("[%s]: failed to create nugen kset\n", __FUNCTION__);
	   return -ENOMEM;
	}
    cust_dev = create_custDev_dev("foo", &cust_dev_ktype);
	if (!cust_dev)
		goto cust_dev_error;
    
	return ret;

cust_dev_error:
	destroy_custDev_dev (cust_dev);
	return -EINVAL;
}

/*
* 
*/
static void 
custDev_sysfs_exit(void)
{
    DEBUGI("[%s]: enter\n", __FUNCTION__);
	destroy_custDev_dev(cust_dev);
	kset_unregister(cust_dev_kset);
}

/*
* set up interrupt
*/
static inline int 
custDev_setup_eint(void)
{
    int ret = 0;
    DEBUGI("[%s]: enter\n", __FUNCTION__);
//#if 0	
//	mt_set_gpio_mode(GPIO_EINT6_COMM_WAKEUP_AP, GPIO_EINT6_COMM_WAKEUP_AP_M_EINT);
//    mt_set_gpio_dir(GPIO_EINT6_COMM_WAKEUP_AP, GPIO_DIR_IN);
//	mt_set_gpio_pull_enable(GPIO_EINT6_COMM_WAKEUP_AP, GPIO_PULL_DISABLE);
//	mt_set_gpio_pull_select(GPIO_EINT6_COMM_WAKEUP_AP, GPIO_PULL_DOWN);		
//#endif	
//    mt65xx_eint_set_sens(CUST_EINT_COMMS_WAKEUP_NUM, CUST_EINT_COMMS_WAKEUP_SENSITIVE);
//    mt65xx_eint_set_polarity(CUST_EINT_COMMS_WAKEUP_NUM, CUST_EINT_COMMS_WAKEUP_POLARITY);
//    mt65xx_eint_set_hw_debounce(CUST_EINT_COMMS_WAKEUP_NUM, 0); //debounce time	
//	mt65xx_eint_registration(CUST_EINT_COMMS_WAKEUP_NUM, CUST_EINT_COMMS_WAKEUP_DEBOUNCE_EN,
//  	                         CUST_EINT_COMMS_WAKEUP_POLARITY, nugen_comms_wakeup_eint_handler, 0);
//							 
//#if 0						 
//	mt_set_gpio_mode(GPIO_EINT8_MEM_EVENT_INT, GPIO_EINT8_MEM_EVENT_INT_M_EINT);
//    mt_set_gpio_dir(GPIO_EINT8_MEM_EVENT_INT, GPIO_DIR_IN);
//	mt_set_gpio_pull_enable(GPIO_EINT8_MEM_EVENT_INT, GPIO_PULL_DISABLE);
//	mt_set_gpio_pull_select(GPIO_EINT8_MEM_EVENT_INT, GPIO_PULL_DOWN);
//#endif
//	mt65xx_eint_set_sens(CUST_EINT_ME_EVENT_NUM, CUST_EINT_ME_EVENT_SENSITIVE);						 
//	mt65xx_eint_set_polarity(CUST_EINT_ME_EVENT_NUM, CUST_EINT_ME_EVENT_POLARITY);
//	mt65xx_eint_set_hw_debounce(CUST_EINT_ME_EVENT_NUM, 0);
//	mt65xx_eint_registration(CUST_EINT_ME_EVENT_NUM, CUST_EINT_ME_EVENT_DEBOUNCE_EN, 
//	                         CUST_EINT_ME_EVENT_POLARITY, nugen_me_event_eint_handler, 0);									 
//	
//	mt65xx_eint_unmask(CUST_EINT_COMMS_WAKEUP_NUM);
//	mt65xx_eint_unmask(CUST_EINT_ME_EVENT_NUM);	
    return ret;
}

/*
* 
*/
static int __init 
custDev_module_init(void) /* Constructor */
{
    
    int ret = 0;
    
    DEBUGI("[%s]: customize driver module registered\n", __FUNCTION__);
	
	
    		
	ret = custDev_sysfs_init();
	if(ret)
	{
        DEBUGE("[%s]: customize driver sysfs init failed.\n", __FUNCTION__);
		return ret;
	}
	
    ret = custDev_setup_eint();
	return ret;	
}

/*
* 
*/ 
static void __exit 
custDev_module_exit(void) /* Destructor */
{
    DEBUGI("[%s]: customize driver module unregistered\n", __FUNCTION__);	
	custDev_sysfs_exit();	
}
 
module_init(custDev_module_init);
module_exit(custDev_module_exit);
 
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Adam Chen <xxx@xxx.com.tw>");
MODULE_DESCRIPTION("Customize driver module");