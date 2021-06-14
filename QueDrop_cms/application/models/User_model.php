<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class User_model extends MY_Model
{
	/**
	 * @var boolean
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

	public function update_user($data){ 
		$this->db->set($data);
        $this->db->where('user_id', $data['user_id']); 
		$this->db->update('users');
		return true; 
	}

	public function get_users(){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('users');
		$this->db->where('is_delete',0);
		$this->db->where("(login_as='Customer/Driver' OR login_as='Customer')", NULL, FALSE);
		$this->db->order_by('user_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
