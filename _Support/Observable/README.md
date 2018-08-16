# Observable: a Block-Based KVO Implementation #


---
Observable is a simple way to get notified about changes to properties of other objects. At its simplest, you can write code like:

```C
	Observe(ValidatePaths(modelObject, aStringProperty) { myLabel.text = modelObject.aStringProperty; });
```
and your label's text will update whenever the model object's string property changes. 
Observable is designed to be much easier to use than Apple's KVO. It's also much easier to debug and about as lightweight.

Observable is much less finicky than Apple's KVO implementation; deallocing an observed or observing object won't throw exceptions; neither will doubly stopping an observation. Observable also supports observable container classes. These are subclasses of NSMutableArray, Set, and Dictionary that can be observed. 

Plus, Observable has a LazyLoader subclass that lets you create lazily loaded computed properties and declare a list of dependent properties that cause the computed property to invalidate its value.

## Audience ##
iOS developers, although the code could pretty easily be ported to Mac OS X. Observable requires iOS 9 and ARC.

More specifically, Observable is for people looking for a better way to hook up their model objects to controllers, and have become frustrated with Apple's KVO.

## Documentation ##

Observable is fully documented, including documentation on how it works internally, what the edge cases are, and how to debug code that uses it. 

## Creator ##

My name is Chall Fry. I wrote this. Ben Yarger helped write test cases and did QE work. Mark Yuan helped get eBay to open-source it.

## Usage ##

```
#pragma mark Demos

- (void) runBasicObservationDemo
{
ModelObject1 *model1 = [[ModelObject1 alloc] init];
[model1 tell:self when:@"intProperty" changes:^(TestWindowViewController *blockSelf, ModelObject1 *observed)
{
NSLog(@"New value is:%d", observed.intProperty);
}];


model1.intProperty = 5;
[model1 setIntProperty:-1];

[model1 stopTelling:self aboutChangesTo:@"intProperty"];
}

- (void) runMacroDemo
{
modelObj2.stringProperty = @"meh";
ObserveProperty(modelObj2, intProperty,
{
NSLog(@"int Property is now %d", observed.intProperty);
});

NSLog(@"%@", [modelObj2 debugShowAllObservers]);

StopObservingPath(modelObj2, intProperty);
}

- (void) runMultipleObservationDemo
{
ModelObject2 *model2 = [[ModelObject2 alloc] init];

[model2 tell:self when:@"*" changes:^(TestWindowViewController *me, ModelObject2 *obj)
{
NSLog(@"Model2 new int prop:%d new string prop: %@", obj.intProperty, obj.stringProperty);
NSLog(@"Model2 range property: %d, %d", (int) obj.rangeProperty.location, (int) obj.rangeProperty.length);
}];

model2.intProperty = 5;
model2.stringProperty = @"stringthing";
model2.intProperty = 17;
[model2 setStringProperty:@"thisisastring"];

model2.rangeProperty = NSMakeRange(33, 2);
}

- (void) runPerfTest
{
double startTime;

ModelObject3 *model3 = [[ModelObject3 alloc] init];

// Test 1: No observation, set the value 100000 times.
startTime = CFAbsoluteTimeGetCurrent();
for (int index = 0; index < 100000; ++index)
{
model3.intProperty = index;
}
double noKVODurationSecs = CFAbsoluteTimeGetCurrent() - startTime;

// Test 2: With observations
startTime = CFAbsoluteTimeGetCurrent();

// Put 100 observerations on the object
__block int totalObservationCount = 0;
for (int index = 0; index < 100; ++index)
{
[model3 tell:self when:@"intProperty" changes:^(TestWindowViewController *me, ModelObject3 *obj)
{
++totalObservationCount;
}];
}

// And set the value 100000 times
for (int index = 0; index < 100000; ++index)
{
model3.intProperty = index;
}
double kvoDurationSecs = CFAbsoluteTimeGetCurrent() - startTime;
NSLog(@"With KVO: %f seconds. Without: %f seconds.", kvoDurationSecs, noKVODurationSecs);


// Test 2: make a Model Object 4, which has 100 int properties
startTime = CFAbsoluteTimeGetCurrent();
ModelObject4 *model4 = [[ModelObject4 alloc] init];

// Start and then stop observing all of them. Individually.
[self observe100PropertiesOfModel4:model4];
[self stopObserving100PropertiesOfModel4:model4];

// Or, use the * forms
//    [model4 tell:self when:@"*" changes:^(TestWindowViewController *me, ModelObject4 *obj) { }];
//    [model4 stopTellingAboutChanges:self];

double observe100DurationSecs = CFAbsoluteTimeGetCurrent() - startTime;
NSLog(@"%f seconds to observe 100 properties, or %f per property.", observe100DurationSecs, observe100DurationSecs / 100);

}

- (void) runVCTest
{
SubViewController *subVC = [[SubViewController alloc] init];
[self presentViewController:subVC animated:YES completion:^{}];
}

- (void) testWithOS_KVO
{
modelObj2.intProperty = 71;

// Set up our KVO on "intProperty"
[modelObj2 tell:self when:@"intProperty" changes:^(id observingObj, id observedObj)
{
NSLog(@"ModelObj2 intProperty changed. New value:%d", modelObj2.intProperty);
}];

// And set up Apple's KVO on the same property
[modelObj2 addObserver:self forKeyPath:@"intProperty" options:NSKeyValueObservingOptionNew context:nil];

// Change the property's value
modelObj2.intProperty = 72;

[modelObj2 removeObserver:self forKeyPath:@"intProperty"];
[modelObj2 stopTelling:self aboutChangesTo:@"intProperty"];
}

- (void) runMultithreadTortureTest
{
modelObj4 = [[ModelObject4 alloc] init];
runningTortureTest = YES;

[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timerDone:)
userInfo:nil repeats:NO];

for (int numThreads = 0; numThreads < 10; ++numThreads)
{
[NSThread detachNewThreadSelector:@selector(tortureTest_startEndObservations) toTarget:self withObject:nil];
[NSThread detachNewThreadSelector:@selector(tortureTest_setValues) toTarget:self withObject:nil];
}
}

- (void) tortureTest_startEndObservations
{
while (runningTortureTest)
{
//        NSLog(@"Observing and then stopping all properties.");
[self observe100PropertiesOfModel4:modelObj4];
[self stopObserving100PropertiesOfModel4:modelObj4];
}
}

- (void) tortureTest_setValues
{
int newValueForAllProperties = 0;

while (runningTortureTest)
{
//        NSLog(@"Setting the value of all properties to %d", newValueForAllProperties);
[self setAll100PropertiesOfModel4: modelObj4 toValue:newValueForAllProperties];
newValueForAllProperties++;
}
}

- (void) timerDone:(NSTimer *) timer
{
runningTortureTest = NO;

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),
^{
NSLog(@"Torture Test complete.");
});

[modelObj4 stopTellingAboutChanges:self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
context:(void *)context
{
if ([keyPath isEqual:@"intProperty"])
{
NSLog(@"ModelObj2 iOS KVO hit for %@. New value is:%d", keyPath,
[[change objectForKey:NSKeyValueChangeNewKey] intValue]);
}
}


- (void) observedObjectHasBeenDealloced:(id) object
{
NSLog(@"Object: %@ sent dealloc notification", [object debugDescription]);
}
```
