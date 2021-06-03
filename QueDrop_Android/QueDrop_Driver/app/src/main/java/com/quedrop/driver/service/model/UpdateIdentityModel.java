package com.quedrop.driver.service.model;

import android.widget.ImageView;

public class UpdateIdentityModel {

    private int position;

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public ImageView getImageView() {
        return imageView;
    }

    public void setImageView(ImageView imageView) {
        this.imageView = imageView;
    }

    public UpdateIdentityModel(int position, String imagePath, ImageView imageView) {
        this.position = position;
        this.imagePath = imagePath;
        this.imageView = imageView;
    }

    private String imagePath="";
    private ImageView imageView;
}
