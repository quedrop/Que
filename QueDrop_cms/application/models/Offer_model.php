<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Offer_model extends MY_Model
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

	public function get_offers(){
		$select = '*,admin_offers.is_active as is_active';
        $this->db->select($select, FALSE);
        $this->db->from('admin_offers');
		$this->db->where('admin_offers.is_delete',0);
		$this->db->where('admin_offers.user_id',0);
		$this->db->join('store', 'store.store_id=admin_offers.store_id', 'LEFT');
		$this->db->order_by('admin_offers.admin_offer_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_order($id) {
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('order_stores');
		$this->db->where('admin_offer_id',$id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_one($id) {
		$select = '*,admin_offers.is_active as is_active';
        $this->db->select($select, FALSE);
		$this->db->from('admin_offers');
		$this->db->where('admin_offers.admin_offer_id',$id);
		$this->db->where('admin_offers.is_delete',0);
		$this->db->join('store', 'store.store_id=admin_offers.store_id', 'LEFT');
		$this->db->order_by('admin_offers.admin_offer_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_selected($where,$table_name) {
		$this->db->select('*');
        $this->db->from($table_name);
		$this->db->where($where);
		$this->db->where('is_delete',0);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
