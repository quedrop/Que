<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Deals extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('deal_model', 'deals');
		$this->load->model('role_model', 'roles');
		$this->load->model('user_permission_model', 'user_permissions');
	}

	/**
	 * Loads the list of deals.
	 */
	public function index()
	{
		$this->set_page_title(_l('deals'));

		if (!has_permissions('deals', 'view'))
		{
			$this->access_denied('deals', 'view');
		}
		else
		{
			$data['deals'] = $this->deals->get_all();
			$data['roles'] = $this->roles->get_all();

			$data['content'] = $this->load->view('admin/deals/index', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('deals').' | '._l('add'));

		if (!has_permissions('deals', 'create'))
		{
			$this->access_denied('deals', 'create');
		}
		else

		if ($this->input->post())
		{
			$data = array
				(

				'deal_name' => $this->input->post('deal_name'),
				'deal_description' => $this->input->post('deal_description'),
				'deal_value' => $this->input->post('deal_value'),
                'date_created' => $this->input->post('date_created'),
                'date_expired' => $this->input->post('date_expired'),
				'is_active' => 1
			);

			$insert = $this->deals->insert($data);

			log_activity("New Deal Created [ID: $insert]");

			$role_id = $this->input->post('role');
			$role    = $this->roles->get($role_id);

			$permissions = unserialize($role['permissions']);

			foreach ($permissions as $key => $permission)
			{
				foreach ($permission as $key_permission => $value)
				{
					$data = array
						('user_id'     => $insert,
						'features'     => $key,
						'capabilities' => $value);

					$permission_insert = $this->user_permissions->insert($data);
				}
			}

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('deals')));
				redirect('admin/deals');
			}
		}
		else
		{
			$data['roles']   = $this->roles->get_all();
			$data['content'] = $this->load->view('admin/deals/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Updates the user record
	 *
	 * @param int  $id  The user id
	 */
	public function edit($id = '')
	{
		$this->set_page_title(_l('deals').' | '._l('edit'));

		if (!has_permissions('deals', 'edit'))
		{
			$this->access_denied('deals', 'edit');
		}
		else

		if ($id)
		{
			if ($this->input->post())
			{
					$data = array
					(
						'deal_name' => $this->input->post('deal_name'),
						'deal_description'  => $this->input->post('deal_description'),
						'deal_value'     => $this->input->post('deal_value'),
                        'date_created' => $this->input->post('date_created'),
                        'date_expired' => $this->input->post('date_expired'),
						'is_active' => ($this->input->post('is_active')) ? 1 : 0
					);
				
				$update = $this->deals->update($id, $data);

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('deals')));
					log_activity("Deal Updated [ID: $id]");
					redirect('admin/deals');
				}
            }
            
                $data['deal']  = $this->deals->get($id);
				$data['roles'] = $this->roles->get_all();

				$data['content'] = $this->load->view('admin/deals/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
							
		}
		else
		{
			redirect('admin/deals');
		}
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('is_active' => $this->input->post('is_active'));

		$update = $this->deals->update($user_id, $data);

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
		$deleted = $this->deals->delete($user_id);

		if ($deleted)
		{
			log_activity("Deal Deleted [ID: $user_id]");
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
		$deleted = $this->deals->delete_many($where);

		if ($deleted)
		{
			$ids = implode(',', $where);
			log_activity("deals Deleted [IDs: $ids]");
			echo 'true';
		}
		else
		{	
			echo 'false';
		}
	}
}
