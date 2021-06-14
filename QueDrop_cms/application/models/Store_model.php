<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Store_model extends MY_Model
{
	/**
	 * @var boolean
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

	public function get_banners($store_id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('store_slider_images');
		$this->db->where('store_id',$store_id);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_schedule($store_id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('store_schedule');
		$this->db->where('store_id',$store_id);
		$this->db->order_by('schedule_id', 'ASC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_user($user_id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('users');
		$this->db->where('user_id',$user_id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_supplier(){
		$select = 'users.user_id as user_id,users.first_name,users.last_name';
		$this->db->distinct();
        $this->db->select($select, FALSE);
        $this->db->from('users');
		$this->db->where('users.login_as','Supplier');
		$this->db->where('users.is_delete',0);
		$this->db->join('store', 'store.user_id!=users.user_id', 'LEFT');
		$query = $this->db->get();
		// echo $this->db->last_query(); exit;
        $result = $query->result_array(); 
        return $result;
	}

	// public function get_one_banners($id){
	// 	$select = '*';
    //     $this->db->select($select, FALSE);
    //     $this->db->from('store_slider_images');
	// 	$this->db->where('slider_image_id',$id);
	// 	$query = $this->db->get();
    //     $result = $query->result_array(); 
    //     return $result;
	// }
}
