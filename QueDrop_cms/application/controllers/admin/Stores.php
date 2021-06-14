<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Stores extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('store_model', 'stores');
		$this->load->model('role_model', 'roles');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of stores.
	 */
	public function index()
	{
		$this->set_page_title(_l('stores'));
		$data['stores'] = $this->common->get_all('store','store_id');
		$data['content'] = $this->load->view('admin/stores/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
		
	}
	public function verify_store($id=''){
		if ($this->input->post()){
			$data = array
				(
					'is_verified' => ($this->input->post('verify_store')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s')
				);
				$where = array('store_id'=>$id);
				$update = $this->common->update($data,$where,'store');
				if ($update)
				{
					set_alert('success', 'Verify Store Successfully');
					log_activity("Store Updated [ID: $id]");
					redirect('admin/stores');
				}
		}
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('stores').' | '._l('add'));

		if ($this->input->post())
		{
			
			if(!empty($_FILES['store_logo']['name']))
        	{
				$_FILES['file']['name']     = $_FILES['store_logo']['name'];
				$_FILES['file']['type']     = $_FILES['store_logo']['type'];
				$_FILES['file']['tmp_name'] = $_FILES['store_logo']['tmp_name'];
				$_FILES['file']['error']     = $_FILES['store_logo']['error'];
				$_FILES['file']['size']     = $_FILES['store_logo']['size'];

				$temp = explode(".", $_FILES['store_logo']['name']);
				$imagename = "logo_".round(microtime(true)) . '.' . end($temp);
			    $config['upload_path'] = UPLOADS_STORES_LOGO;
				$config['allowed_types'] = 'gif|jpg|png|jpeg';
				$config['file_name'] = $imagename;
				$this->load->library('upload', $config);
				$this->upload->initialize($config);
				if($this->upload->do_upload('file')){
					$fileData = $this->upload->data();
				}
				else
				{
						$error = array('error' => $this->upload->display_errors()); 
				}
			}
			$data = array
			(
				'store_name' => $this->input->post('store_name'),
				'store_address'  => $this->input->post('store_address'),
				'service_category_id'  => $this->input->post('service_cat'),
				'user_id' => $this->input->post('user'),
				'latitude'=>$this->input->post('store_latitude'),
				'longitude'=>$this->input->post('store_longitude'),
				'can_provide_service'=>$this->input->post('can_service_provider'),
				'is_active' => 1,
				'store_logo'=>$imagename,
				'is_testdata'=>1,
				'created_at' => date('Y-m-d H:i:s')

			);
			$insert = $this->common->insert($data,'store');

			if(!empty($insert)){
				if(!empty($_FILES['store_banner_images']['name'])){
					echo $count = count($_FILES['store_banner_images']['name']);
					for($i = 0; $i<$count;$i++){
						$_FILES['file']['name']     = $_FILES['store_banner_images']['name'][$i];
						$_FILES['file']['type']     = $_FILES['store_banner_images']['type'][$i];
						$_FILES['file']['tmp_name'] = $_FILES['store_banner_images']['tmp_name'][$i];
						$_FILES['file']['error']     = $_FILES['store_banner_images']['error'][$i];
						$_FILES['file']['size']     = $_FILES['store_banner_images']['size'][$i];

						$temp = explode(".", $_FILES['store_banner_images']['name'][$i]);
						$imagename = "store_".round(microtime(true)).$i. '.' . end($temp);
						$config['upload_path'] = UPLOADS_STORES_STORES_S;
						$config['allowed_types'] = 'gif|jpg|png|jpeg';
						$config['file_name'] = $imagename;
						$this->load->library('upload', $config);
						$this->upload->initialize($config);
						if($this->upload->do_upload('file')){
							$fileData = $this->upload->data();
							$banner_image_array = array(
								'slider_image'=>$imagename,
								'store_id'=>$insert,
								'is_testdata'=>1,
								'created_at' => date('Y-m-d H:i:s')
							);
							$insert_banner = $this->common->insert($banner_image_array,'store_slider_images');
						}
						else
						{
								$error = array('error' => $this->upload->display_errors()); 
						}
								
					}
				}

				if(!empty($this->input->post('open_time')) && !empty($this->input->post('close_time'))){
					$count_time = count($this->input->post('open_time'));
					for($j=0;$j<$count_time;$j++){
						$data_time = array(
							'store_id'=>$insert,
							'opening_time'=>$this->input->post('open_time')[$j],
							'closing_time'=>$this->input->post('close_time')[$j],
							'weekday'=>$this->input->post('weekday')[$j],
							'is_closed'=>$this->input->post('is_closed')[$j],
							'is_testdata'=>1,
							'created_at'=>date('Y-m-d H:i:s')
						);
						$insert_schedule = $this->common->insert($data_time,'store_schedule');
					}
				}

				$get_user_details =  $this->stores->get_user($this->input->post('user'));
				if(!empty($get_user_details)){
					$to = $get_user_details[0]['email'];
					$password = $get_user_details[0]['password'];
					$temp_data['email']=array('email' => $to,'password'=>$password,'name'=>$get_user_details[0]['first_name']);
					$msg_template=  $this->load->view('admin/stores/email_template',$temp_data,true);
					$this->load->helper('mail_helper');
					$send_email = send_email($to,'Login Details',$msg_template);
				}
			}
			

			
			log_activity("New Store Created [ID: $insert]");

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('stores')));
				redirect('admin/stores');
			}
		}
		else
		{
			$data['roles']   = $this->roles->get_all();
			$data['service_category'] = $this->common->get_all('service_category');
			$array_data = array(
				'field1'=>'login_as',
				'value1'=>'Customer',
				'field2'=>'is_delete',
				'value2'=>0
			);
			$data['users'] = $this->stores->get_supplier();
 			$data['content'] = $this->load->view('admin/stores/create', $data, TRUE);
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
		$this->set_page_title(_l('stores').' | '._l('edit'));
		if ($id)
		{
			if ($this->input->post())
			{
					if(!empty($_FILES['store_logo']['name']))
					{
						$_FILES['file']['name']     = $_FILES['store_logo']['name'];
						$_FILES['file']['type']     = $_FILES['store_logo']['type'];
						$_FILES['file']['tmp_name'] = $_FILES['store_logo']['tmp_name'];
						$_FILES['file']['error']     = $_FILES['store_logo']['error'];
						$_FILES['file']['size']     = $_FILES['store_logo']['size'];
		
						$temp = explode(".", $_FILES['store_logo']['name']);
						$imagename = "logo_".round(microtime(true)) . '.' . end($temp);
						$config['upload_path'] = UPLOADS_STORES_LOGO;
						$config['allowed_types'] = 'gif|jpg|png|jpeg';
						$config['file_name'] = $imagename;
						$this->load->library('upload', $config);
						$this->upload->initialize($config);
						if($this->upload->do_upload('file')){
							$fileData = $this->upload->data();
							if(!empty($this->input->post('old_logo')))
							{
								unlink(UPLOADS_STORES_LOGO.$this->input->post('old_logo'));  
							}
						}
						else
						{
								$error = array('error' => $this->upload->display_errors()); 
						}
					} else {
						$imagename = $this->input->post('old_logo');
					}
					$data = array
					(
						'store_name' => $this->input->post('store_name'),
						'store_address'  => $this->input->post('store_address'),
						'service_category_id'  => $this->input->post('service_cat'),
						'latitude'=>$this->input->post('store_latitude'),
						'longitude'=>$this->input->post('store_longitude'),
						'can_provide_service'=>$this->input->post('can_service_provider'),
						'user_id' => $this->input->post('user'),
						'is_active' => ($this->input->post('is_active')) ? 1 : 0,
						'store_logo'=>$imagename,
						'is_testdata'=>1,
						'updated_at'=>date('Y-m-d H:i:s')

					);
					$where = array('store_id'=>$id);
				
				$update = $this->common->update($data,$where,'store');
				if(!empty($this->input->post('schedule_id'))){
					$count_time = count($this->input->post('schedule_id'));
					for($j=0;$j<$count_time;$j++){
						$data_time = array(
							'store_id'=>$id,
							'opening_time'=>$this->input->post('open_time')[$j],
							'closing_time'=>$this->input->post('close_time')[$j],
							'weekday'=>$this->input->post('weekday')[$j],
							'is_closed'=>$this->input->post('is_closed')[$j],
							'is_testdata'=>1,
							'updated_at'=>date('Y-m-d H:i:s')
						);
						$where_time = array('schedule_id'=>$this->input->post('schedule_id')[$j]);
						$update_schedule = $this->common->update($data_time,$where_time,'store_schedule');
					}
				}
				if(!empty($this->input->post('delete_banner'))){
					$delete_img = $this->input->post('delete_banner');
					$delete_img_array = explode(",",$delete_img);
					foreach($delete_img_array as $img){
						$up_arrauy = array(
							'is_delete'=>1,
							'updated_at'=>date('Y-m-d H:i:s')
						);
						$where_up = array('slider_image_id'=>$img);
						$update_banner = $this->common->update($up_arrauy,$where_up,'store_slider_images');
						// $get_imge = $this->stores->get_one_banners($img);
						// if(!empty($get_imge)){
						// 	$image_name = $get_imge[0]['slider_image'];
						// }
					}
				}

				if(!empty($_FILES['store_banner_images']['name'])){
					echo $count = count($_FILES['store_banner_images']['name']);
					for($i = 0; $i<$count;$i++){
						$_FILES['file']['name']     = $_FILES['store_banner_images']['name'][$i];
						$_FILES['file']['type']     = $_FILES['store_banner_images']['type'][$i];
						$_FILES['file']['tmp_name'] = $_FILES['store_banner_images']['tmp_name'][$i];
						$_FILES['file']['error']     = $_FILES['store_banner_images']['error'][$i];
						$_FILES['file']['size']     = $_FILES['store_banner_images']['size'][$i];

						$temp = explode(".", $_FILES['store_banner_images']['name'][$i]);
						$imagename = "store_".round(microtime(true)).$i. '.' . end($temp);
						$config['upload_path'] = UPLOADS_STORES_STORES_S;
						$config['allowed_types'] = 'gif|jpg|png|jpeg';
						$config['file_name'] = $imagename;
						$this->load->library('upload', $config);
						$this->upload->initialize($config);
						if($this->upload->do_upload('file')){
							$fileData = $this->upload->data();
							$banner_image_array = array(
								'slider_image'=>$imagename,
								'store_id'=>$id,
								'is_testdata'=>1,
								'created_at' => date('Y-m-d H:i:s')
							);
							$insert_banner = $this->common->insert($banner_image_array,'store_slider_images');
						}
						else
						{
								$error = array('error' => $this->upload->display_errors()); 
						}
								
					}
				}

				if(!empty($this->input->post('selected_supplier'))){
					if($this->input->post('selected_supplier') != $this->input->post('user')){
						$to_user = $this->input->post('user');
						$get_user_details =  $this->stores->get_user($to_user);
						if(!empty($get_user_details)){
							$to = $get_user_details[0]['email'];
							$password = $get_user_details[0]['password'];
							$temp_data['email']=array('email' => $to,'password'=>$password,'name'=>$get_user_details[0]['first_name']);
							$msg_template=  $this->load->view('admin/stores/email_template',$temp_data,true);
							$this->load->helper('mail_helper');
							$send_email = send_email($to,'Login Details',$msg_template);
						}
					}
				}

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('stores')));
					log_activity("User Updated [ID: $id]");
					redirect('admin/stores');
				}
            }
				$array_val = array('field1'=>'store_id','value1'=>$id,'field2'=>'is_delete','value2'=>0);
				$store = $this->common->edit($array_val,'store');
                $data['store']  = $store[0];
				$data['roles'] = $this->roles->get_all();
				$data['service_category'] = $this->common->get_all('service_category');
				$array_data = array(
					'field1'=>'login_as',
					'value1'=>'Customer',
					'field2'=>'is_delete',
					'value2'=>0
				);
				$data['users'] = $this->stores->get_supplier();
				$data['store_banners'] = $this->stores->get_banners($id);
				$data['store_schedule'] = $this->stores->get_schedule($id);
				$data['content'] = $this->load->view('admin/stores/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
							
		}
		else
		{
			redirect('admin/stores');
		}
	}

	public function view($id= ''){
		$array_val = array('field1'=>'store_id','value1'=>$id,'field2'=>'is_delete','value2'=>0);
		$store = $this->common->edit($array_val,'store');
		$data['store']  = $store[0];
		$data['roles'] = $this->roles->get_all();
		$data['service_category'] = $this->common->get_all('service_category');
		if(!empty($store[0])) {
			$data['users'] = $this->stores->get_user($store[0]['user_id']);
		}
		$data['store_banners'] = $this->stores->get_banners($id);
		$data['store_schedule'] = $this->stores->get_schedule($id);
		$data['content'] = $this->load->view('admin/stores/view', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array(
			'is_active' => $this->input->post('is_active'),
		);
		$where = array('store_id'=>$user_id);

		$update = $this->common->update($data,$where,'store');

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
		$data = array('is_delete'=>1);
		$where = array('store_id'=>$user_id);
		$deleted = $this->common->update($data,$where,'store');
		$image_delete = $this->common->update($data,$where,'store_slider_images');
		$schedule_delete = $this->common->update($data,$where,'store_schedule');

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
		// $deleted = $this->stores->delete_many($where);
		foreach($where as $id) {
			$data = array(
				'is_delete'=>1
			);
			$wh = array('store_id'=>$id);
			$deleted = $this->common->update($data,$wh,'store');
			$image_delete = $this->common->update($data,$wh,'store_slider_images');
			$schedule_delete = $this->common->update($data,$wh,'store_schedule');
		}
		$ids = implode(',', $where);
		log_activity("Stores Deleted [IDs: $ids]");
		echo 'true';
		
	}
}
