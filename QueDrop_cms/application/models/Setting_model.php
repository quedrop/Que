<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class setting_model extends MY_Model
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

	}

	public function get_values() {
		$this->db->select('*');
		$this->db->from('values_config');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;		
	}
}
