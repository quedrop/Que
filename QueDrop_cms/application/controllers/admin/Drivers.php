<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Drivers extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('driver_model', 'drivers');
		$this->load->model('role_model', 'roles');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of drivers.
	 */
	public function index()
	{
		$this->set_page_title(_l('drivers'));
		$get_driver = array(
			'field1'=>'login_as',
			'value1'=>'Driver',
			'field2'=>'is_delete',
			'value2'=>0
		);
		$data['drivers'] = $this->drivers->drivers();
		$data['roles'] = $this->roles->get_all();

		$data['content'] = $this->load->view('admin/drivers/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
		
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('drivers').' | '._l('add'));

		if ($this->input->post())
		{
			$data = array
				(

				'firstname' => $this->input->post('firstname'),
				'lastname'  => $this->input->post('lastname'),
				'email'     => $this->input->post('email'),
				'mobile_no' => $this->input->post('mobile_no'),
				'is_active' => 1,
				'created_at'=>date('Y-m-d H:i:s'),
				'is_testdata'=>1
			);

			$insert = $this->drivers->insert($data);

			log_activity("New Driver Created [ID: $insert]");

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
				set_alert('success', _l('_added_successfully', _l('driver')));
				redirect('admin/drivers');
			}
		}
		else
		{
			$data['drivers'] = $this->drivers->get_driver();
			$data['roles']   = $this->roles->get_all();
			$data['content'] = $this->load->view('admin/drivers/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Updates the user record
	 *
	 * @param int  $id  The user id
	 */
	public function view($id = ''){
		$drivers = $this->drivers->get_one($id);
		$data['driver']  =  $drivers[0];
		$data['vehicle_type'] = $this->common->get_all('vehicle_type');
		$data['roles'] = $this->roles->get_all();

		$data['content'] = $this->load->view('admin/drivers/view', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	public function verify_driver($id=''){
		if ($this->input->post()){
			$data = array
				(
					'is_driver_verified' => ($this->input->post('verify_driver')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s')
				);
				$where = array('user_id'=>$id);
				$update = $this->common->update($data,$where,'users');
				if ($update)
				{
					set_alert('success', 'Verify Driver Successfully');
					log_activity("User Updated [ID: $id]");
					redirect('admin/drivers');
				}
		}
	}

	public function edit($id = '')
	{
		$this->set_page_title(_l('drivers').' | '._l('edit'));
		if ($id)
		{
			if ($this->input->post())
			{
				$data = array
				(
					'first_name' => $this->input->post('firstname'),
					'last_name'  => $this->input->post('lastname'),
					'email'     => $this->input->post('email'),
					'phone_number' => $this->input->post('mobile_no'),
					'active_status' => ($this->input->post('is_active')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s'),
					'is_testdata'=>1
				);
				$where = array('user_id'=>$id);
				$update = $this->common->update($data,$where,'users');

				if(!empty($_FILES['licence_photo']['name']))
				{
					$_FILES['file']['name']     = $_FILES['licence_photo']['name'];
					$_FILES['file']['type']     = $_FILES['licence_photo']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['licence_photo']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['licence_photo']['error'];
					$_FILES['file']['size']     = $_FILES['licence_photo']['size'];
	
					$temp = explode(".", $_FILES['licence_photo']['name']);
					$licence_image = "Licence_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_DRIVERS_IMG;
					$config['allowed_types'] = 'gif|jpg|png|jpeg';
					$config['file_name'] = $licence_image;
					$this->load->library('upload', $config);
					$this->upload->initialize($config);
					if($this->upload->do_upload('file')){
						$fileData = $this->upload->data();
						if(!empty($this->input->post('old_logo')))
						{
							unlink(UPLOADS_DRIVERS_IMG.$this->input->post('old_licence'));  
						}
					}
					else
					{
							$error = array('error' => $this->upload->display_errors()); 
					}
				} else {
					$licence_image = $this->input->post('old_licence');
				}
				if(!empty($_FILES['registration_proof']['name']))
				{
					$_FILES['file']['name']     = $_FILES['registration_proof']['name'];
					$_FILES['file']['type']     = $_FILES['registration_proof']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['registration_proof']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['registration_proof']['error'];
					$_FILES['file']['size']     = $_FILES['registration_proof']['size'];
	
					$temp = explode(".", $_FILES['registration_proof']['name']);
					$registration_proof = "RegistrationProof_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_DRIVERS_IMG;
					$config['allowed_types'] = 'gif|jpg|png|jpeg';
					$config['file_name'] = $registration_proof;
					$this->load->library('upload', $config);
					$this->upload->initialize($config);
					if($this->upload->do_upload('file')){
						$fileData = $this->upload->data();
						if(!empty($this->input->post('old_logo')))
						{
							unlink(UPLOADS_DRIVERS_IMG.$this->input->post('old_registration_proof'));  
						}
					}
					else
					{
							$error = array('error' => $this->upload->display_errors()); 
					}
				} else {
					$registration_proof = $this->input->post('old_registration_proof');
				}
				if(!empty($_FILES['number_plate']['name']))
				{
					$_FILES['file']['name']     = $_FILES['number_plate']['name'];
					$_FILES['file']['type']     = $_FILES['number_plate']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['number_plate']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['number_plate']['error'];
					$_FILES['file']['size']     = $_FILES['number_plate']['size'];
	
					$temp = explode(".", $_FILES['number_plate']['name']);
					$number_plate = "NumberPlate_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_DRIVERS_IMG;
					$config['allowed_types'] = 'gif|jpg|png|jpeg';
					$config['file_name'] = $number_plate;
					$this->load->library('upload', $config);
					$this->upload->initialize($config);
					if($this->upload->do_upload('file')){
						$fileData = $this->upload->data();
						if(!empty($this->input->post('old_logo')))
						{
							unlink(UPLOADS_DRIVERS_IMG.$this->input->post('old_number_plate'));  
						}
					}
					else
					{
							$error = array('error' => $this->upload->display_errors()); 
					}
				} else {
					$number_plate = $this->input->post('old_number_plate');
				}

				$detail_array = array(
				  'vehicle_type_id'=>$this->input->post('vehicle_type'),
				  'licence_photo'=>$licence_image,
				  'registration_proof'=>$registration_proof,
				  'number_plate'=>$number_plate,
				  'updated_at'=>date('Y-m-d H:i:s'),
				  'is_testdata'=>1
				);
				$details_update = $this->common->update($detail_array,$where,'driver_identity_detail');
				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('user')));
					log_activity("User Updated [ID: $id]");
					redirect('admin/drivers');
				}
            }
				$drivers = $this->drivers->get_one($id);
				$data['driver']  =  $drivers[0];
				$data['vehicle_type'] = $this->common->get_all('vehicle_type');
				$data['roles'] = $this->roles->get_all();

				$data['content'] = $this->load->view('admin/drivers/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
							
		}
		else
		{
			redirect('admin/drivers');
		}
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('is_active' => $this->input->post('is_active'));

		$update = $this->drivers->update($user_id, $data);

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
			'is_delete'=>2,
			'updated_at'=>date('Y-m-d H:i:s')
		);
		$where = array('user_id'=>$user_id);
		$deleted = $this->common->update($data,$where,'users');
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
				'is_delete'=>2,
				'updated_at'=>date('Y-m-d H:i:s')
			);
			$wh = array('user_id'=>$id);
			$deleted = $this->common->update($data,$wh,'users');
		}
		$ids = implode(',', $where);
		log_activity("drivers Deleted [IDs: $ids]");
		echo 'true';
		
	}
}
