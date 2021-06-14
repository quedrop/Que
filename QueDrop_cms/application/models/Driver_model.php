<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Driver_model extends MY_Model
{
	/**
	 * @var boolean
	 */
	protected $soft_delete = TRUE;

	/**
	 * @var string
	 */
	protected $soft_delete_key = 'is_deleted';
	protected $table_name = 'users';

	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

	}

	public function drivers(){
		$select = '*';
        $this->db->select($select, FALSE);
		$this->db->from('users');
		$this->db->where("(login_as='Customer/Driver' OR login_as='Driver')", NULL, FALSE);
		$this->db->where('is_delete',0);
		$this->db->order_by('user_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_driver(){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('users');
		$this->db->where("(login_as='Customer/Driver' OR login_as='Driver')", NULL, FALSE);
		$this->db->where('users.is_delete',0);
		$this->db->join('driver_identity_detail', 'driver_identity_detail.user_id=users.user_id', 'LEFT');
		// $this->db->join('vehicle_type', 'vehicle_type.vehicle_type_id=driver_identity_detail.vehicle_type_id', 'LEFT');
		$this->db->order_by('users.user_id', 'DESC');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_one($id) {
		$select = '*,users.user_id as user_id';
        $this->db->select($select, FALSE);
        $this->db->from('users');
		$this->db->where('users.user_id',$id);
		$this->db->join('driver_identity_detail', 'driver_identity_detail.user_id=users.user_id', 'LEFT');
		// $this->db->join('vehicle_type', 'vehicle_type.vehicle_type_id=driver_identity_detail.vehicle_type_id', 'LEFT');
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
