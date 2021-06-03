package com.quedrop.driver.utils

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.graphics.RectF
import android.media.ThumbnailUtils
import androidx.exifinterface.media.ExifInterface
import java.io.IOException
import java.io.InputStream


class BitmapUtils() {

    companion object {
        private const val PHOTO_TARGET_SIZE: Int = 1024

        fun getBitmapFromIntent( appContext: Context,data: Intent?): Bitmap? {
            data?.let {
                val uri = data.data
                uri?.let {
                    val bitmapOptions = BitmapFactory.Options()
                    bitmapOptions.inJustDecodeBounds = true
                    var inputStream: InputStream? = appContext.contentResolver.openInputStream(uri)

                    inputStream?.let { bitmapInfoStream ->
                        val orientation = getImageOrientation(bitmapInfoStream)

                        BitmapFactory.decodeStream(bitmapInfoStream, null, bitmapOptions)
                        bitmapInfoStream.close()

                        val width = bitmapOptions.outWidth
                        val height = bitmapOptions.outHeight
                        val scaleFactor =
                            Math.min(width / PHOTO_TARGET_SIZE, height / PHOTO_TARGET_SIZE)

                        bitmapOptions.inJustDecodeBounds = false
                        bitmapOptions.inSampleSize = scaleFactor

                        inputStream = appContext.contentResolver.openInputStream(uri)
                        inputStream?.let { inputStream ->
                            // get bitmap with rough scale
                            val bitmap = BitmapFactory.decodeStream(inputStream, null, bitmapOptions)
                            inputStream.close()

                            bitmap?.let {
                                val matrix = Matrix()
                                val inRect =
                                    RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())
                                val outRect = RectF(
                                    0f,
                                    0f,
                                    PHOTO_TARGET_SIZE.toFloat(),
                                    PHOTO_TARGET_SIZE.toFloat()
                                )
                                val values = FloatArray(9)

                                matrix.setRectToRect(inRect, outRect, Matrix.ScaleToFit.CENTER)
                                matrix.getValues(values)

                                // exact scale
                                val resizedBitmap = Bitmap.createScaledBitmap(
                                    bitmap,
                                    (bitmap.width * values[0]).toInt(),
                                    (bitmap.height * values[4]).toInt(),
                                    true
                                )

                                val rotatedBitmap =
                                    rotateImageBasedOnExifInfo(resizedBitmap, orientation)

                                if (rotatedBitmap != null) {
                                    // returns centered bitmap of the desired size
                                    return ThumbnailUtils.extractThumbnail(
                                        rotatedBitmap,
                                        PHOTO_TARGET_SIZE,
                                        PHOTO_TARGET_SIZE
                                    )
                                }

                            }
                        }
                    }
                }
            }
            return null
        }

        private fun getImageOrientation(inputStream: InputStream): Int {
            var exif: ExifInterface? = null

            try {
                exif = ExifInterface(inputStream)
            } catch (e: IOException) {

            }

            return exif?.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_UNDEFINED
            ) ?: ExifInterface.ORIENTATION_UNDEFINED
        }

        private fun rotateImageBasedOnExifInfo(bitmap: Bitmap, orientation: Int): Bitmap? {
            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_NORMAL -> return bitmap
                ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.setScale(-1f, 1f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
                ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                    matrix.setRotate(180f)
                    matrix.postScale(-1f, 1f)
                }
                ExifInterface.ORIENTATION_TRANSPOSE -> {
                    matrix.setRotate(90f)
                    matrix.postScale(-1f, 1f)
                }
                ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
                ExifInterface.ORIENTATION_TRANSVERSE -> {
                    matrix.setRotate(-90f)
                    matrix.postScale(-1f, 1f)
                }
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(-90f)
                else -> return bitmap
            }
            return try {
                val bitmapRotated = Bitmap
                    .createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
                bitmap.recycle()
                bitmapRotated
            } catch (e: OutOfMemoryError) {

                null
            }
        }
    }
}