//
//  ALMacros.h
//  AppLovinSDK
//
//  Created by Thomas So on 1/1/22.
//

NS_ASSUME_NONNULL_BEGIN

NS_INLINE BOOL isMainQueue (void)
{
    return [NSThread isMainThread];
}

NS_INLINE void deferToNextMainQueueRunloop (void (^block)(void))
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: block];
}

NS_INLINE void dispatchOnMainQueueNow (void (^block)(void))
{
    dispatch_async(dispatch_get_main_queue(), block);
}

NS_INLINE void dispatchOnMainQueue (void (^block)(void))
{
    if ( isMainQueue() )
    {
        block();
    }
    else
    {
        deferToNextMainQueueRunloop(block);
    }
}

NS_INLINE void dispatchOnMainQueueImmediate (void (^block)(void))
{
    if ( isMainQueue () )
    {
        block();
    }
    else
    {
        dispatchOnMainQueueNow(block);
    }
}

NS_INLINE void dispatchOnMainQueueAfter (double delay, dispatch_block_t __nonnull block)
{
    if ( delay > 0 )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
    else
    {
        dispatchOnMainQueueImmediate(block);
    }
}

NS_INLINE void dispatchOnMainQueueAfterAndDeferToNextMainQueueRunloop (double delay, dispatch_block_t __nonnull block)
{
    if ( delay > 0 )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
    else
    {
        deferToNextMainQueueRunloop(block);
    }
}

NS_INLINE void dispatchSyncOnMainQueue (dispatch_block_t __nonnull block)
{
    // Cannot call dispatch_sync on same queue results in deadlock - so just run op if main queue already
    if ( isMainQueue() )
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NS_ASSUME_NONNULL_END
