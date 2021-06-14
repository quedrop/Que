<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Users extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('user_model', 'users');
		$this->load->model('common_model', 'common');
		$this->load->model('role_model', 'roles');
		$this->load->model('user_permission_model', 'user_permissions');
	}

	/**
	 * Loads the list of users.
	 */
	public function index()
	{
		$this->set_page_title(_l('users'));
		$data['users'] = $this->users->get_users(); 
		$data['content'] = $this->load->view('admin/users/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
		
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('users').' | '._l('add'));

		// if (!has_permissions('users', 'create'))
		// {
		// 	$this->access_denied('users', 'create');
		// }
		// else

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

			// if ($this->input->post('role') == 1)
			// {
			// 	$data['is_admin'] = 1;
			// }
			// else
			// {
			// 	$data['is_admin'] = 0;
			// }

			$insert = $this->users->insert($data);

			log_activity("New User Created [ID: $insert]");

			$role_id = $this->input->post('role');
			$role    = $this->roles->get($role_id);

			// $permissions = unserialize($role['permissions']);

			// foreach ($permissions as $key => $permission)
			// {
			// 	foreach ($permission as $key_permission => $value)
			// 	{
			// 		$data = array
			// 			('user_id'     => $insert,
			// 			'features'     => $key,
			// 			'capabilities' => $value);

			// 		$permission_insert = $this->user_permissions->insert($data);
			// 	}
			// }

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('user')));
				redirect('admin/users');
			}
		}
		else
		{
			$data['roles']   = $this->roles->get_all();
			$data['content'] = $this->load->view('admin/users/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	public function email_exists()
	{
		$exists = $this->users->count_by('email', $this->input->post('email'));
		echo $exists; exit;

		echo $exists;
	}

	/**
	 * Updates the user record
	 *
	 * @param int  $id  The user id
	 */
	public function edit($id = '')
	{
		$this->set_page_title(_l('users').' | '._l('edit'));

		// if (!has_permissions('users', 'edit'))
		// {
		// 	$this->access_denied('users', 'edit');
		// }
		// else

		if ($id)
		{
			if ($this->input->post())
			{	
				if ($this->input->post('newpassword') == NULL)
				{
					$data = array
						(
						'first_name' => $this->input->post('firstname'),
						'last_name'  => $this->input->post('lastname'),
						'email'     => $this->input->post('email'),
						'phone_number' => $this->input->post('mobile_no'),
						'login_as'      => $this->input->post('role'),
						'active_status' => ($this->input->post('is_active')) ? 1 : 0
					);
				}
				else
				{
					$data = array
						(
						'first_name' => $this->input->post('firstname'),
						'last_name'  => $this->input->post('lastname'),
						'email'     => $this->input->post('email'),
						'phone_number' => $this->input->post('mobile_no'),
						'password'  => md5($this->input->post('newpassword')),
						'login_as'      => $this->input->post('role'),
						'active_status' => ($this->input->post('is_active')) ? 1 : 0
					);
				}
				$data['user_id'] = $id;
				$update = $this->users->update_user($data);

				// $this->user_permissions->delete_by(array('user_id' => $id));

				$role_id   = $this->input->post('role');
				$role_data = $this->roles->get_by(array('id' => $role_id));

				// $permissions = unserialize($role_data['permissions']);

				// foreach ($permissions as $key => $permission)
				// {
				// 	if ($permission != NULL)
				// 	{
				// 		foreach ($permission as $key_permission => $value)
				// 		{
				// 			$data = array
				// 				('user_id'     => $id,
				// 				'features'     => $key,
				// 				'capabilities' => $value);

				// 			$permission_insert = $this->user_permissions->insert($data);
				// 		}
				// 	}
				// }

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('user')));
					log_activity("User Updated [ID: $id]");
					redirect('admin/users');
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
				$data['user']  = $users[0];
				$data['roles'] = $this->roles->get_all();

				if (get_loggedin_user_id() == $id)
				{
					redirect('admin/profile/edit');
				}
				else
				{
					$data['content'] = $this->load->view('admin/users/edit', $data, TRUE);
					$this->load->view('admin/layouts/index', $data);
				}
			}
		}
		else
		{
			redirect('admin/users');
		}
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

	/**
	 * Deletes the single user record
	 */
	public function delete()
	{
		$user_id = $this->input->post('user_id');
		$data = array(
			'user_id'=>$user_id,
			'is_delete'=>2,
			'updated_at'=>date('Y-m-d H:i:s')
		);
		$deleted = $this->users->update_user($data);

		if ($deleted)
		{
			log_activity("User Deleted [ID: $user_id]");
			echo 'true';
		}
		else
		{
			echo 'false';
		}
	}

	/**
	 * Deletes multiple user records
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
		// $deleted = $this->users->delete_many($where);

		// if ($deleted)
		// {
			$ids = implode(',', $where);
			log_activity("Users Deleted [IDs: $ids]");
			echo 'true';
		// }
		// else
		// {
		// 	echo 'false';
		// }
	}
}
