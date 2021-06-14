<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Suppliers extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('supplier_model', 'suppliers');
		$this->load->model('user_model', 'users');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of suppliers.
	 */
	public function index()
	{
		$this->set_page_title(_l('suppliers'));
			$data['suppliers'] = $this->suppliers->get_users();
			$data['content']  = $this->load->view('admin/suppliers/index', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		
	}

	/**
	 * Add new project
	 */
	public function add()
	{
		$this->set_page_title(_l('suppliers').' | '._l('add'));

		

		if ($this->input->post())
		{
			$data = array
			(
				'first_name' => $this->input->post('firstname'),
				'last_name'  => $this->input->post('lastname'),
				'email'     => $this->input->post('email'),
				'phone_number' => $this->input->post('mobile_no'),
				'password'  => md5($this->input->post('password')),
				'login_as'      => $this->input->post('role'),
				'active_status' => 1,
				'is_testdata'=>1,
				'created_at' => date('Y-m-d H:i:s')
			);

			$insert = $this->users->insert($data);

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('supplier')));
				log_activity("New supplier Created [ID:$insert]");
				redirect('admin/suppliers');
			}
		}
		else
		{
			$data['content'] = $this->load->view('admin/suppliers/create', '', TRUE);
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
		$this->set_page_title(_l('suppliers').' | '._l('edit'));

		if ($id)
		{
			if ($this->input->post())
			{
				$data = array
					(
					'first_name' => $this->input->post('firstname'),
					'last_name'=> $this->input->post('lastname'),
					'email' => $this->input->post('email'),
					'phone_number' => $this->input->post('mobile_no'),
					'login_as'      => $this->input->post('role'),
					'active_status' => ($this->input->post('is_active')) ? 1 : 0,
					'updated_at' => date('Y-m-d H:i:s')
				);

				if(!empty($this->input->post('newpassword'))){
					$data['password'] = md5($this->input->post('newpassword'));
				}

				$data['user_id'] = $id;
				$update = $this->users->update_user($data);

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('supplier')));
					log_activity("supplier Updated [ID:$id]");
					redirect('admin/suppliers');
				}
			}
			else
			{
				$array = array(
					'field1'=>'user_id',
					'value1'=>$id,
					'field2'=>'is_delete',
					'value2'=>0
				);
				$users = $this->common->edit($array,'users');
				$data['supplier']  = $users[0];
				$data['content'] = $this->load->view('admin/suppliers/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
			}
		}
		else
		{
			redirect('admin/suppliers');
		}
	}

	/**
	 * Deletes the single project record
	 */
	public function delete()
	{
		$project_id = $this->input->post('supplier_id');
		$data = array(
			'user_id'=>$project_id,
			'is_delete'=>2,
			'updated_at'=>date('Y-m-d H:i:s')
		);
		$deleted = $this->users->update_user($data);

		if ($deleted)
		{
			log_activity("supplier Deleted");
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
				'user_id'=>$id,
				'is_delete'=>2,
				'updated_at'=>date('Y-m-d H:i:s')
			);
			$deleted = $this->users->update_user($data);
		}

		$ids = implode(',', $where);
		log_activity("Users Deleted [IDs: $ids]");
		echo 'true';
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('user_id'=>$user_id,'active_status' => $this->input->post('is_active'));

		$update = $this->users->update_user($data);

		if ($update)
		{
			if ($this->input->post('is_active') == 1)
			{
				echo 'true';
			}
			else
			{
				echo 'false';
			}
		}
	}
}
