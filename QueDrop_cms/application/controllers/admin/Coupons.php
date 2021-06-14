<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Coupons extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('coupon_model', 'coupons');
		$this->load->model('role_model', 'roles');
		$this->load->model('user_permission_model', 'user_permissions');
	}

	/**
	 * Loads the list of coupons.
	 */
	public function index()
	{
		$this->set_page_title(_l('coupons'));

		if (!has_permissions('coupons', 'view'))
		{
			$this->access_denied('coupons', 'view');
		}
		else
		{
			$data['coupons'] = $this->coupons->get_all();
			$data['roles'] = $this->roles->get_all();

			$data['content'] = $this->load->view('admin/coupons/index', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('coupons').' | '._l('add'));

		if (!has_permissions('coupons', 'create'))
		{
			$this->access_denied('coupons', 'create');
		}
		else

		if ($this->input->post())
		{
			$data = array
				(

				'coupon_code' => $this->input->post('coupon_code'),
				'coupon_description'  => $this->input->post('coupon_description'),
				'max_usage_per_user'     => $this->input->post('max_usage_per_user'),
				'is_active' => 1
			);

			$insert = $this->coupons->insert($data);

			log_activity("New Coupon Created [ID: $insert]");

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
				set_alert('success', _l('_added_successfully', _l('coupons')));
				redirect('admin/coupons');
			}
		}
		else
		{
			$data['roles']   = $this->roles->get_all();
			$data['content'] = $this->load->view('admin/coupons/create', $data, TRUE);
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
		$this->set_page_title(_l('coupons').' | '._l('edit'));

		if (!has_permissions('coupons', 'edit'))
		{
			$this->access_denied('coupons', 'edit');
		}
		else

		if ($id)
		{
			if ($this->input->post())
			{
					$data = array
					(
						'coupon_code' => $this->input->post('coupon_code'),
						'coupon_description'  => $this->input->post('coupon_description'),
						'max_usage_per_user'     => $this->input->post('max_usage_per_user'),
						'is_active' => ($this->input->post('is_active')) ? 1 : 0
					);
				
				$update = $this->coupons->update($id, $data);

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('coupons')));
					log_activity("Coupon Updated [ID: $id]");
					redirect('admin/coupons');
				}
            }
            
                $data['coupon']  = $this->coupons->get($id);
				$data['roles'] = $this->roles->get_all();

				$data['content'] = $this->load->view('admin/coupons/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
							
		}
		else
		{
			redirect('admin/coupons');
		}
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('is_active' => $this->input->post('is_active'));

		$update = $this->coupons->update($user_id, $data);

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
		$deleted = $this->coupons->delete($user_id);

		if ($deleted)
		{
			log_activity("Store Deleted [ID: $user_id]");
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
		$deleted = $this->coupons->delete_many($where);

		if ($deleted)
		{
			$ids = implode(',', $where);
			log_activity("coupons Deleted [IDs: $ids]");
			echo 'true';
		}
		else
		{	
			echo 'false';
		}
	}
}
