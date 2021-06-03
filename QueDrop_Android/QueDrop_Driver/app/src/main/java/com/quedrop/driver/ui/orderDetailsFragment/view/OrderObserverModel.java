package com.quedrop.driver.ui.orderDetailsFragment.view;


import com.quedrop.driver.service.model.Stores;

public class OrderObserverModel {

    public int position;
    public  Stores stores;

    public OrderObserverModel(int position, Stores stores) {
        this.position = position;
        this.stores = stores;
    }
}
