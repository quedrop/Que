<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Delivery_address_model extends MY_Model
{
	/**
	 * @var mixed
	 */
	protected $soft_delete = TRUE;
	
	/**
	 * @var string
	 */
	protected $soft_delete_key = 'is_delete';
	
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

	}

	public function get_address($id=''){
		$this->db->select('*');
		$this->db->from('delivery_addresses');
		if(!empty($id)){
			$this->db->where('delivery_address_id',$id);
		}
        $this->db->where('is_delete',0);
        $query = $this->db->get();
        $result = $query->result(); 
        return $result;
	}

	public function update_address($id,$data){
		$this->db->set($data);
        $this->db->where('delivery_address_id',$id); 
		$this->db->update('delivery_addresses');
		return true; 
	}

	public function check_exist($address){
		$this->db->select('address');
		$this->db->from('delivery_addresses');
		$this->db->where('address',$address);
        $this->db->where('is_delete',0);
        $query = $this->db->get();
        $result = $query->result(); 
        return $result;
	}

	

}
