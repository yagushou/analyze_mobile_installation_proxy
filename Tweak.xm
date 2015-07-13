#import "substrate.h"
#include "stdio.h"
#define size_t unsigned int


size_t (* original_lockdown_receive_message)(void *,void **);
size_t (* original_lockdown_send_message)(void *,void *,size_t);

size_t hook_lockdown_receive_message(void *s,void **message)
{
	int ret=0;
	ret=original_lockdown_receive_message(s,message);
	NSLog(@"receive message \n%@",(NSDictionary *)*message);
	return ret;
}

size_t hook_lockdown_send_message(void *s,void *message,size_t message_lenth)
{
	NSLog(@"send message \n%@",(NSDictionary *)message);
	return original_lockdown_send_message(s,message,message_lenth);
}

%ctor
{
	void *lockdown_receive_message=NULL;
	void *lockdown_send_message=NULL;
	//redirect stderr
	if(0==freopen("/var/log/hook_message","a+",stderr))
	{
		NSLog(@"redirect stderr fail %d",errno);		
	}	
	lockdown_receive_message=MSFindSymbol(NULL,"_lockdown_receive_message");
	lockdown_send_message=MSFindSymbol(NULL,"_lockdown_send_message");
	MSHookFunction(lockdown_receive_message,(void *)hook_lockdown_receive_message,(void **)&original_lockdown_receive_message);
	MSHookFunction(lockdown_send_message,(void *)hook_lockdown_send_message,(void **)&original_lockdown_send_message);
}
