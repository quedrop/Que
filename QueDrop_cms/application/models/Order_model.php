<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Order_model extends MY_Model
{
	/**
	 * @var mixed
	 */
	protected $soft_delete = TRUE;
	
	/**
	 * @var string
	 */
	protected $soft_delete_key = 'is_deleted';
	
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

	}

	public function get_details(){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('orders');
		$this->db->where('orders.is_delete',0);
		$this->db->join('users', 'users.user_id=orders.user_id', 'LEFT');
		// $this->db->join('customer_address', 'customer_address.address_id=orders.address_id', 'LEFT');
		$this->db->order_by('orders.order_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_all_orders($id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('orders');
		$this->db->where('orders.is_delete',0);
		$this->db->where('orders.order_id',$id);
		$this->db->join('users', 'users.user_id=orders.user_id', 'LEFT');
		$this->db->order_by('orders.order_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_driver($id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('order_driver');
		$this->db->where('order_driver.is_delete',0);
		$this->db->where('order_driver.order_id',$id);
		$this->db->join('users', 'users.user_id=order_driver.user_id', 'LEFT');
		$this->db->order_by('order_driver.order_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_pro($order_id) {
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('order_stores');
		$this->db->where('order_stores.order_id',$order_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_store($store_id) {
	    $select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('store');
		$this->db->where('store_id',$store_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;		
	}

	public function get_user_store($store_id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('user_store');
		$this->db->where('user_store_id',$store_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function get_user_products_details($id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('user_store_product');
		$this->db->where('user_product_id',$id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function get_product($store_id){
		$select = '*';
		$this->db->select($select, FALSE);
        $this->db->from('order_store_products');
		$this->db->where('order_store_id',$store_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;		
	}

	public function get_products_details($product_id){
		$select = '*';
		$this->db->select($select, FALSE);
        $this->db->from('product');
		$this->db->where('product_id',$product_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function get_addons($product_id) {
		$select = '*';
		$this->db->select($select, FALSE);
        $this->db->from('order_customisation');
		$this->db->where('order_store_product_id',$product_id);
		$this->db->join('product_addons', 'product_addons.addon_id=order_customisation.addon_id', 'LEFT');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function get_payment_details($id){
		$select = '*';
		$this->db->select($select, FALSE);
        $this->db->from('admin_payments');
		$this->db->where('order_id',$id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function insert_payment($data){
        $this->db->insert('admin_payments',$data);
        return $this->db->insert_id();
	}
	
	public function update_payment($data){ 
		$this->db->set($data);
        $this->db->where('order_id',$data['order_id']); 
		$this->db->update('admin_payments');
		return true; 
	}
	
	public function get_values(){
		$select = '*';
		$this->db->select($select, FALSE);
        $this->db->from('values_config');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	public function driver_payment($data){
		$this->db->insert('weekly_payment_details',$data);
        return $this->db->insert_id();
	}

	public function get_driver_payment(){
		$select = '*';
		$this->db->select($select, FALSE);
		$this->db->from('weekly_payment_details');
		$this->db->where('is_manual_store_amount',1); 
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;	
	}

	
	public function update_driver_payment($data){ 
		$this->db->set($data);
        $this->db->where('weekly_payment_id',$data['weekly_payment_id']); 
		$this->db->update('weekly_payment_details');
		return true; 
	}

	
}

