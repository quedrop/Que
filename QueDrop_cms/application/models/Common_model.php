<?php

class Common_model extends CI_Model {

    public function edit($data,$table_name) {
        $this->db->select('*');
        $this->db->from($table_name);
        $this->db->where($data['field1'],$data['value1']);
        if(!empty($data['field2'])) { 
            $this->db->where('is_delete',0);
        }
        $query = $this->db->get(); 
        $result = $query->result_array();
        return $result; 
    }

    public function delete($data){
        $this->db->where($data['field_name'], $data['field_value']);
        $this->db->delete($data['table_name']);
        return true;
    }

    public function get_all($tbl_name,$id = ''){
        $this->db->select('*');
        $this->db->from($tbl_name);
        $this->db->where('is_delete',0);
        if(!empty($id)) {
            $this->db->order_by($id, 'DESC');
        }
        $query = $this->db->get();
        $result = $query->result_array(); 
        return $result;
    }

    public function update($data,$where,$table_name){ 
		$this->db->set($data);
        $this->db->where($where); 
		$this->db->update($table_name);
		return true; 
    }
    
    public function insert($data,$table_name){
        $this->db->insert($table_name,$data);
        return $this->db->insert_id();
    }

    

}