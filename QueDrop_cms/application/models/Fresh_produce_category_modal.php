<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class fresh_produce_category_modal extends MY_Model
{
	/**
	* @var mixed
	*/
	protected $soft_delete = TRUE;
	
	/**
	 * @var string
	 */
	protected $_table ='fresh_produce_category';
	protected $soft_delete_key = 'is_deleted';
	
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
	
    }
    
    public function insert_cat($data) {
        $this->db->insert('fresh_produce_category',$data);
        return $this->db->insert_id();  
    }


	public function get_category(){
		$select = '*';
        $this->db->select($select, FALSE);
		$this->db->from('fresh_produce_category');
		$this->db->where('fresh_produce_category.is_delete',0);
		$this->db->order_by('fresh_produce_category.fresh_category_id', 'DESC');
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}

	public function get_one($id){
		$select = '*';
        $this->db->select($select, FALSE);
        $this->db->from('fresh_produce_category');
		$this->db->where('fresh_produce_category.is_delete',0);
		$this->db->where('fresh_produce_category.fresh_category_id',$id);
		$query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
	}
}
