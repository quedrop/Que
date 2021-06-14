<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class category_model extends MY_Model
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

	public function insert_cat($data) {
        $this->db->insert('store_food_category',$data);
        return $this->db->insert_id();  
    }

	public function get_category(){
		$select = '*,store_food_category.is_active as is_active';
        $this->db->select($select, FALSE);
        $this->db->from('store_food_category');
		$this->db->where('store_food_category.is_delete',0);
		$this->db->join('store', 'store.store_id=store_food_category.store_id', 'LEFT');
		$this->db->order_by('store_food_category.store_category_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_one($id){
		$select = '*,store_food_category.is_active as is_active';
        $this->db->select($select, FALSE);
        $this->db->from('store_food_category');
		$this->db->where('store_food_category.is_delete',0);
		$this->db->where('store_food_category.store_category_id',$id);
		$this->db->join('store', 'store.store_id=store_food_category.store_id', 'LEFT');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
