<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Payment_model extends MY_Model
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

    public function get_voucher($start,$end){
        $this->db->select('*');
        $this->db->from('driver_refferal_voucher');
        $this->db->where('created_at BETWEEN "'. date('Y-m-d', strtotime($start)). '" and "'. date('Y-m-d', strtotime($end)).'"');
        $this->db->where('is_delete',0);
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_orders($start,$end){
        $this->db->select('*,order_driver.user_id as user_id,orders.user_id as c_id');
        $this->db->from('order_driver');
        $this->db->join('orders', 'orders.order_id=order_driver.order_id', 'LEFT');
        $this->db->where('orders.created_at BETWEEN "'. date('Y-m-d', strtotime($start)). '" and "'. date('Y-m-d', strtotime($end)).'"');
        $this->db->where('orders.order_status','Delivered');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_store_orders($start,$end){
        $this->db->select('*');
        $this->db->from('order_stores');
        $this->db->join('orders', 'orders.order_id=order_stores.order_id', 'LEFT');
        $this->db->where('orders.created_at BETWEEN "'. date('Y-m-d', strtotime($start)). '" and "'. date('Y-m-d', strtotime($end)).'"');
        $this->db->where('orders.order_status','Delivered');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }



    public function get_drivers(){
        $this->db->select('*');
        $this->db->from('users');
        $this->db->where('is_delete',0);
        $this->db->where('login_as','Driver');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_order($id){
        $this->db->select('*');
        $this->db->from('orders');
        $this->db->where('order_id',$id);
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_percentage(){
        $this->db->select('*');
        $this->db->from('values_config');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_driver_details($id){ 
        $this->db->select('*');
        $this->db->from('users');
        $this->db->where('is_delete',0);
        // $this->db->where('login_as','Customer/Driver');
        $this->db->where('user_id',$id);
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_store($id){
        $this->db->select('*');
        $this->db->from('store');
        $this->db->where('is_delete',0);
        $this->db->where('store_id',$id);
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_store_payments($id,$start_date,$end_date){
        $this->db->select('*');
        $this->db->from('order_stores');
        $this->db->where('store_id',$id);
        $this->db->join('orders', 'orders.order_id=order_stores.order_id', 'LEFT');
        $this->db->where('orders.created_at BETWEEN "'. date('Y-m-d', strtotime($start_date)). '" and "'. date('Y-m-d', strtotime($end_date)).'"');
        $this->db->where('orders.order_status','Delivered');
        $this->db->order_by('order_store_id', 'ASC');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_store_wk_payments($id,$date){
        $this->db->select('*');
        $this->db->from('order_stores');
        $this->db->where('created_at BETWEEN DATE_SUB('.$date.', INTERVAL 7 DAY) AND NOW()');
        // $this->db->where('is_delete',0);
        $this->db->where('store_id',$id);
        $this->db->order_by('order_store_id', 'ASC');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_driver_payments($id,$start_date,$end_date){
        $this->db->select('*,order_driver.user_id as user_id,orders.user_id as c_id');
        $this->db->from('order_driver');
        $this->db->join('orders', 'orders.order_id=order_driver.order_id', 'LEFT');
        $this->db->where('orders.created_at BETWEEN "'. date('Y-m-d', strtotime($start_date)). '" and "'. date('Y-m-d', strtotime($end_date)).'"');
        $this->db->where('orders.order_status','Delivered');
        $this->db->where('order_driver.user_id',$id);
        $query = $this->db->get();
        
        $result = $query->result_array(); 
        
        return $result;
    }

    public function get_voucher_details($id,$start_date,$end_date){
        $this->db->select('*');
        $this->db->from('driver_refferal_voucher');
        $this->db->where('user_id',$id);
        $this->db->where('created_at BETWEEN "'. date('Y-m-d', strtotime($start_date)). '" and "'. date('Y-m-d', strtotime($end_date)).'"');
        $this->db->where('is_delete',0);
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result; 
    }

    public function get_bank_details($id){
        $this->db->select('*');
        $this->db->from('bank_details');
        $this->db->where('bank_details.is_delete',0);
        $this->db->where('bank_details.user_id',$id);
        $this->db->join('bank_list', 'bank_list.bank_id=bank_details.bank_id', 'LEFT');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function insert_payment($data){
        $this->db->insert('weekly_payment_details',$data);
        return $this->db->insert_id();
    }

    public function get_store_week_pay($id,$start_date,$end_date){
        $this->db->select('*');
        $this->db->from('weekly_payment_details');
        $this->db->where('is_store',1);
        $this->db->where('driver_store_id',$id);
        $this->db->where('week_start_date',date('Y-m-d', strtotime($start_date)));
        $this->db->where('week_end_date',date('Y-m-d', strtotime($end_date)));
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function get_pay_deivers($id,$start_date,$end_date){
        $this->db->select('*');
        $this->db->from('weekly_payment_details');
        $this->db->where('is_driver',1);
        $this->db->where('driver_store_id',$id);
        $this->db->where('week_start_date',date('Y-m-d', strtotime($start_date)));
        $this->db->where('week_end_date',date('Y-m-d', strtotime($end_date)));
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function update_payment($data){ 
		$this->db->set($data);
        $this->db->where('weekly_payment_id',$data['weekly_payment_id']); 
		$this->db->update('weekly_payment_details');
		return $data['weekly_payment_id']; 
    }

    public function update_voucher($data){
        $this->db->set($data);
        $this->db->where('voucher_id',$data['voucher_id']); 
		$this->db->update('driver_refferal_voucher');
	}

}