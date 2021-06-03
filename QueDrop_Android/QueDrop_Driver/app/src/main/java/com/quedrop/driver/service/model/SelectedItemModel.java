package com.quedrop.driver.service.model;

public class SelectedItemModel {

    int position;
    boolean selected;

    public SelectedItemModel(int position, boolean selected) {
        this.position = position;
        this.selected = selected;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }
}
