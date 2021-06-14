<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Delivery_address extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('delivery_address_model', 'delivery_address');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of delivery_charge.
	 */

	public function index()
	{
			$this->set_page_title('Delivery Address');
			$data['address'] = $this->delivery_address->get_address(); 
			$data['content']  = $this->load->view('admin/delivery_address/index', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
	}

	public function address_exists()
	{
		if(!empty($this->input->post('address'))){
			$exists = $this->delivery_address->check_exist($this->input->post('address'));
			if(!empty($exists)){
				echo "1";
			} 
		}
	}

	

	/**
	 * Add new project
	 */
	public function add()
	{
		$this->set_page_title('Delivery Address | '._l('add'));

		if ($this->input->post())
		{
			$data = array
			(
				'address'        => $this->input->post('address'),
				'is_testdata' => 1,
				'created_at'=>date('Y-m-d H:i:s')
			);

			$insert = $this->delivery_address->insert($data);

			if ($insert)
			{
				set_alert('success', 'Delivery Address added successfully');
				redirect('admin/delivery_address');
			}
		}
		else
		{
			$data['content'] = $this->load->view('admin/delivery_address/add', '', TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Updates the project record
	 *
	 * @param int  $id  The project id
	 */
	public function edit($id = '')
	{
		$this->set_page_title('Delivery Address | '._l('edit'));

		if ($id)
		{
			
			if ($this->input->post())
			{
				$data = array
					(
					'address'       => $this->input->post('address'),
					'is_testdata' => 1,
					'updated_at'=>date('Y-m-d H:i:s')
				);

				$update = $this->delivery_address->update_address($id, $data);

				if ($update)
				{
					set_alert('success','Delivery Address updated successfully');
					redirect('admin/delivery_address');
				}
			}
			else
			{
				$data['address'] = $this->delivery_address->get_address($id);
				$data['content'] = $this->load->view('admin/delivery_address/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
			}
		}
		else
		{
			redirect('admin/delivery_address');
		}
	}

	/**
	 * Deletes the single project record
	 */
	public function delete()
	{
		$id = $this->input->post('id');
		$data = array(
			'is_delete'=>1,
			'updated_at'=>date('Y-m-d H:i:s')
		);
		$where = array('delivery_address_id'=>$id);
		$deleted    = $this->common->update($data,$where,'delivery_addresses');

		if ($deleted)
		{
			echo 'true';
		}
		else
		{
			echo 'false';
		}
	}

	/**
	 * Deletes multiple project records
	 */
	public function delete_selected()
	{
		$where   = $this->input->post('ids');
		
		foreach($where as $id) {
			$data = array(
				'is_delete'=>1,
				'updated_at'=>date('Y-m-d H:i:s')
			);
			$wh = array('delivery_address_id'=>$id);
			$deleted = $this->common->update($data,$wh,'delivery_addresses');
		}
		$ids = implode(',', $where);
		log_activity("Stores Deleted [IDs: $ids]");
		echo 'true';
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	
}
