<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Product_model extends MY_Model
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

	public function get_products(){
		$select = '*,product.is_active as is_active';
        $this->db->select($select, FALSE);
        $this->db->from('product');
		$this->db->where('product.is_delete',0);
		$this->db->join('store_food_category', 'store_food_category.store_category_id=product.store_category_id', 'LEFT');
		$this->db->order_by('product.product_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_one($id){
		$select = '*,product.is_active as is_active';
        $this->db->select($select, FALSE);
		$this->db->from('product');
		$this->db->where('product.product_id',$id);
		$this->db->where('product.is_delete',0);
		$this->db->join('store_food_category', 'store_food_category.store_category_id=product.store_category_id', 'LEFT');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_category($id){
		$this->db->select('*', FALSE);
		$this->db->from('store_food_category');
		$this->db->where('store_id',$id);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_store_id($id){
		$this->db->select('*', FALSE);
		$this->db->from('store_food_category');
		$this->db->where('store_category_id',$id);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_options($id){
		$this->db->select('*', FALSE);
		$this->db->from('product_options');
		$this->db->where('product_id',$id);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_addons($id){
		$this->db->select('*', FALSE);
		$this->db->from('product_addons');
		$this->db->where('product_id',$id);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
