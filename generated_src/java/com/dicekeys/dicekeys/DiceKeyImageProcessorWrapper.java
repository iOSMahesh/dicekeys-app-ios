// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from DiceKeyImageProcessorWrapper.djinni

package com.dicekeys.dicekeys;

import java.util.concurrent.atomic.AtomicBoolean;

public abstract class DiceKeyImageProcessorWrapper {
    public abstract boolean processRGBAImage(int width, int height, byte[] data);

    public abstract boolean processRGBAImageAndRenderOverlay(int width, int height, byte[] data);

    public abstract boolean processAndAugmentRGBAImage(int width, int height, byte[] data);

    public abstract String readJson();

    public abstract boolean isFinished();

    public abstract byte[] getFaceImage(int faceIndex, int height, byte[] data);

    /**
     * `create()` factory method has to be used to create an instance of the class in Swift/Objective-C/Kotlin/Java
     *
     * For example, in Swift:
     * let wrapper = DKDiceKeyImageProcessorWrapper.create()!
     *
     * in Objective-C:
     * DKDiceKeyImageProcessorWrapper *wrapper = [DKDiceKeyImageProcessorWrapper create];
     */
    public static DiceKeyImageProcessorWrapper create()
    {
        return CppProxy.create();
    }

    private static final class CppProxy extends DiceKeyImageProcessorWrapper
    {
        private final long nativeRef;
        private final AtomicBoolean destroyed = new AtomicBoolean(false);

        private CppProxy(long nativeRef)
        {
            if (nativeRef == 0) throw new RuntimeException("nativeRef is zero");
            this.nativeRef = nativeRef;
        }

        private native void nativeDestroy(long nativeRef);
        public void _djinni_private_destroy()
        {
            boolean destroyed = this.destroyed.getAndSet(true);
            if (!destroyed) nativeDestroy(this.nativeRef);
        }
        protected void finalize() throws java.lang.Throwable
        {
            _djinni_private_destroy();
            super.finalize();
        }

        @Override
        public boolean processRGBAImage(int width, int height, byte[] data)
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_processRGBAImage(this.nativeRef, width, height, data);
        }
        private native boolean native_processRGBAImage(long _nativeRef, int width, int height, byte[] data);

        @Override
        public boolean processRGBAImageAndRenderOverlay(int width, int height, byte[] data)
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_processRGBAImageAndRenderOverlay(this.nativeRef, width, height, data);
        }
        private native boolean native_processRGBAImageAndRenderOverlay(long _nativeRef, int width, int height, byte[] data);

        @Override
        public boolean processAndAugmentRGBAImage(int width, int height, byte[] data)
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_processAndAugmentRGBAImage(this.nativeRef, width, height, data);
        }
        private native boolean native_processAndAugmentRGBAImage(long _nativeRef, int width, int height, byte[] data);

        @Override
        public String readJson()
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_readJson(this.nativeRef);
        }
        private native String native_readJson(long _nativeRef);

        @Override
        public boolean isFinished()
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_isFinished(this.nativeRef);
        }
        private native boolean native_isFinished(long _nativeRef);

        @Override
        public byte[] getFaceImage(int faceIndex, int height, byte[] data)
        {
            assert !this.destroyed.get() : "trying to use a destroyed object";
            return native_getFaceImage(this.nativeRef, faceIndex, height, data);
        }
        private native byte[] native_getFaceImage(long _nativeRef, int faceIndex, int height, byte[] data);

        public static native DiceKeyImageProcessorWrapper create();
    }
}
