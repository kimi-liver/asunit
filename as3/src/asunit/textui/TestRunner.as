package asunit.textui {
    import asunit.framework.Test;
    import asunit.framework.TestResult;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.system.fscommand;
    import flash.utils.clearInterval;
    import flash.utils.describeType;
    import flash.utils.getTimer;
    import flash.utils.setInterval;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.DisplayObject;

    /**
    *   The base class for ActionScript 3.0 test applications.
    *   
    *   The <code>TestRunner</code> should be extended by your
    *   concrete runner for your project.
    *   
    *   If you're building a Flex application, you will need to
    *   extend the <code>FlexRunner</code>
    *   
    *   Your concrete runner will usually look like the following:
    *   <pre>
    *   package {
    *       import asunit.textui.TestRunner;
    *   
    *       public class MyProjectRunner extends TestRunner {
    *       
    *           public function MyProjectRunner() {
    *               // start(clazz:Class, methodName:String, showTrace:Boolean)
    *               // NOTE: sending a particular class and method name will
    *               // execute setUp(), the method and NOT tearDown.
    *               // This allows you to get visual confirmation while developing
    *               // visual entities
    *               start(AllTests, null, TestRunner.SHOW_TRACE);
    *           }
    *       }
    *   }
    *   </pre>
    *   
    *   @see asunit.textui.FlexRunner
    *   @see asunit.textui.AirRunner
    *   @see asunit.textui.XMLResultPrinter
    **/
    public class TestRunner extends Sprite {
        public static const SUCCESS_EXIT:int   = 0;
        public static const FAILURE_EXIT:int   = 1;
        public static const EXCEPTION_EXIT:int = 2;
        public static const SHOW_TRACE:Boolean = true;
        protected var fPrinter:ResultPrinter;
        protected var startTime:Number;
        protected var result:TestResult;

        public function TestRunner() {
            configureListeners();
        }

        private function configureListeners():void {
            addEventListener(Event.ADDED_TO_STAGE, addedHandler);
            addEventListener(Event.ADDED, addedHandler);
        }

        protected function addedHandler(event:Event):void {
            if (!stage)
            {
                return;
            }
            if(event.target === fPrinter) {
                stage.align = StageAlign.TOP_LEFT;
                stage.scaleMode = StageScaleMode.NO_SCALE;
                stage.addEventListener(Event.RESIZE, resizeHandler);
                resizeHandler(new Event("resize"));
            }
        }

        private function resizeHandler(event:Event):void {
            fPrinter.width = stage.stageWidth;
            fPrinter.height = stage.stageHeight;
        }

        /**
         * Starts a test run based on the TestCase/TestSuite provided
         * Create a new custom class that extends TestRunner
         * and call start(TestCaseClass) from within the
         * constructor.
         */
        public function start(testCase:Class, testMethod:String = null, showTrace:Boolean = false):TestResult {
//            fscommand("showmenu", "false");
            try {
                var instance:Test;
                if(testMethod != null) {
                    instance = new testCase(testMethod);
                }
                else {
                    instance = new testCase();
                }
                return doRun(instance, showTrace);
            }
            catch(e:Error) {
                throw new Error("Could not create and run test suite: " + e.getStackTrace());
            }
            return null;
        }

        public function doRun(test:Test, showTrace:Boolean = false):TestResult {
            result = new TestResult();
            if(fPrinter == null) {
                setPrinter(new ResultPrinter(showTrace));
            }
            else {
                fPrinter.setShowTrace(showTrace);
            }
            result.addListener(getPrinter());
            startTime = getTimer();
            test.setResult(result);
            test.setContext(this);
            test.addEventListener(Event.COMPLETE, testCompleteHandler);
            test.run();
            return result;
        }
        
        private function testCompleteHandler(event:Event):void {
            var endTime:Number = getTimer();
            var runTime:Number = endTime - startTime;
            getPrinter().printResult(result, runTime);
        }

        public function setPrinter(printer:ResultPrinter):void {
            if(fPrinter is DisplayObject && getChildIndex(fPrinter)) {
                removeChild(fPrinter);
            }

            fPrinter = printer;
            if(fPrinter is DisplayObject) {
                addChild(fPrinter);
            }
        }

        public function getPrinter():ResultPrinter {
            return fPrinter;
        }
    }
}