<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Servicecategory extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('service_category_model', 'service_category');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of categories.
	 */
	public function index()
	{
		$this->set_page_title(_l('service_category'));
		$data['categories'] = $this->service_category->get_category();
		$data['content']    = $this->load->view('admin/service_category/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
		
	}

	/**
	 * Adds new category
	 */
	public function add()
	{
		$this->set_page_title(_l('service_category').' | '._l('add'));

		if ($this->input->post())
		{
			if(!empty($_FILES['category_image']['name']))
			{
				$_FILES['file']['name']     = $_FILES['category_image']['name'];
				$_FILES['file']['type']     = $_FILES['category_image']['type'];
				$_FILES['file']['tmp_name'] = $_FILES['category_image']['tmp_name'];
				$_FILES['file']['error']     = $_FILES['category_image']['error'];
				$_FILES['file']['size']     = $_FILES['category_image']['size'];

				$temp = explode(".", $_FILES['category_image']['name']);
				$imagename = "Store_Category_".round(microtime(true)) . '.' . end($temp);
				$config['upload_path'] = UPLOADS_PATH_SERVICE_CATEGORIES;
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
			$data = array(
				'service_category_name' => $this->input->post('name'),
				'service_category_description'=>$this->input->post('category_description'),
				'service_category_image'=>$imagename,
				'is_active' => 1,
				'is_testdata'=>1,
				'created_at' => date('Y-m-d H:i:s')
			);
			$insert = $this->service_category->insert_cat($data);

			log_activity("New Category Created [ID: $insert]");

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('category')));
				redirect('admin/servicecategory');
			}
		}
		else
		{
            $data = array();
			$data['content'] = $this->load->view('admin/service_category/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Updates the category record
	 *
	 * @param int  $id  The categoy id
	 */
	public function view($id=''){
		$cat = $this->service_category->get_one($id);
		$data['category'] = $cat[0];
		$data['content']  = $this->load->view('admin/service_category/view', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	public function edit($id = '')
	{
		$this->set_page_title(_l('categories').' | '._l('edit'));

		if ($id)
		{
			if ($this->input->post())
			{  
				if(!empty($_FILES['category_image']['name']))
				{
					$_FILES['file']['name']     = $_FILES['category_image']['name'];
					$_FILES['file']['type']     = $_FILES['category_image']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['category_image']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['category_image']['error'];
					$_FILES['file']['size']     = $_FILES['category_image']['size'];
					//echo $_SERVER['REQUEST_URI'];    
					$temp = explode(".", $_FILES['category_image']['name']);
					$imagename = "Store_Category_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_PATH_SERVICE_CATEGORIES;
					$config['allowed_types'] = 'gif|jpg|png|jpeg';
					$config['file_name'] = $imagename;
					$this->load->library('upload', $config);
					$this->upload->initialize($config);
					// $responseImage = imageUpload('category_image', $config['upload_path'], $imagename);
					// print_r($responseImage);
					// die();
					if($this->upload->do_upload('file')){
						$fileData = $this->upload->data();
						if(!empty($this->input->post('old_image')))
						{
							unlink(UPLOADS_PATH_SERVICE_CATEGORIES.$this->input->post('old_image'));  
						}
					}
					else
					{
							$error = array('error' => $this->upload->display_errors()); 
					}
				} else {
					$imagename = $this->input->post('old_image');
				}
				$data = array(
					'service_category_name' => $this->input->post('name'),
					'service_category_description'=>$this->input->post('category_description'),
					'service_category_image'=>$imagename,
					'is_active' => ($this->input->post('is_active')) ? 1 : 0,
					'updated_at'   => date('Y-m-d H:i:s')
				);
				$where = array('service_category_id'=>$id);
				$update = $this->common->update($data,$where,'service_category');

				if ($update)
				{
					log_activity("Category Updated [ID: $id]");

					set_alert('success', _l('_updated_successfully', _l('category')));
					redirect('admin/servicecategory');
				}
			}
			else
			{
				$cat = $this->service_category->get_one($id);
				$data['category'] = $cat[0];
				$data['content']  = $this->load->view('admin/service_category/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
			}
		}
		else
		{
			redirect('admin/categories');
		}
	}

	/**
	 * Toggles the category status to Active or Inactive
	 */
	public function update_status()
	{
		$category_id = $this->input->post('category_id');
		$data        = [
			'is_active' => $this->input->post('is_active'),
			'updated_at'   => date('Y-m-d H:i:s')
		];
		$where = array('service_category_id'=>$category_id);

		$update = $this->common->update($data,$where,'service_category');

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

		log_activity("Category Status Updated [ID: $category_id]");
	}

	/**
	 * Deletes the single category record
	 */
	public function delete()
	{
		$category_id = $this->input->post('category_id');
		$data = array(
			'is_delete'=>1,
			'updated_at'   => date('Y-m-d H:i:s')
		);
		$where = array('service_category_id'=>$category_id);
		$deleted     = $this->common->update($data,$where,'service_category');

		if ($deleted)
		{
			log_activity("Category Deleted [ID: $category_id]");
			echo 'true';
		}
		else
		{
			echo 'false';
		}
	}

	/**
	 * Deletes multiple category records
	 */
	public function delete_selected()
	{
		$where   = $this->input->post('ids');
		foreach($where as $id) {
			$data = array(
				'is_delete'=>1,
				'updated_at'   => date('Y-m-d H:i:s')
			);
			$wh = array('service_category_id'=>$id);
			$deleted = $this->common->update($data,$wh,'service_category');
		}

		$ids = implode(',', $where);
		log_activity("Categories Deleted [IDs: $ids] ");

		echo 'true';
		
	}
}
