<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Fresh_produce_category extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('fresh_produce_category_modal', 'freshproduce_category');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of categories.
	 */
	public function index()
	{
		$this->set_page_title('Fresh Produce Category');
		$data['categories'] = $this->freshproduce_category->get_category();
		$data['content']    = $this->load->view('admin/fresh_produce_category/index', $data, TRUE);
		// echo "<pre>";
		// print_r($data['categories']);
		// die();
		$this->load->view('admin/layouts/index', $data);
		
	}

	/**
	 * Adds new category
	 */
	public function add()
	{
		$this->set_page_title('Fresh Produce Category'.' | '._l('add'));

		if ($this->input->post())
		{
			if(!empty($_FILES['fresh_produce_image']['name']))
			{
				$_FILES['file']['name']     = $_FILES['fresh_produce_image']['name'];
				$_FILES['file']['type']     = $_FILES['fresh_produce_image']['type'];
				$_FILES['file']['tmp_name'] = $_FILES['fresh_produce_image']['tmp_name'];
				$_FILES['file']['error']     = $_FILES['fresh_produce_image']['error'];
				$_FILES['file']['size']     = $_FILES['fresh_produce_image']['size'];

				$temp = explode(".", $_FILES['fresh_produce_image']['name']);
				$imagename = "Fresh_Produce_Category_".round(microtime(true)) . '.' . end($temp);
				$config['upload_path'] = UPLOADS_CATEGORY;
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
			// print_r($imagename);
			// print_r($this->input->post());
			// die();
			$data = array(
				'fresh_produce_title' => $this->input->post('fresh_produce_title'),
				'fresh_produce_image'=>$imagename,
				'is_testdata'=>1,
				'created_at' => date('Y-m-d H:i:s')
			);
			$insert = $this->freshproduce_category->insert_cat($data);

			log_activity("New Fresh Produce Category Created [ID: $insert]");

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', 'Fresh Produce Category'));
				redirect('admin/fresh_produce_category');
			}
		}
		else
		{
            $data = array();
			$data['content'] = $this->load->view('admin/fresh_produce_category/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	/**
	 * Updates the category record
	 *
	 * @param int  $id  The categoy id
	 */
	public function view($id=''){
		$cat = $this->freshproduce_category->get_one($id);
		$data['category'] = $cat[0];
		$data['content']  = $this->load->view('admin/fresh_produce_category/view', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	public function edit($id = '')
	{
		$this->set_page_title('Fresh Produce Category'.' | '._l('edit'));

		if ($id)
		{
			if ($this->input->post())
			{  
				if(!empty($_FILES['fresh_produce_image']['name']))
				{
					$_FILES['file']['name']     = $_FILES['fresh_produce_image']['name'];
					$_FILES['file']['type']     = $_FILES['fresh_produce_image']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['fresh_produce_image']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['fresh_produce_image']['error'];
					$_FILES['file']['size']     = $_FILES['fresh_produce_image']['size'];
					//echo $_SERVER['REQUEST_URI'];    
					$temp = explode(".", $_FILES['fresh_produce_image']['name']);
					$imagename = "Fresh_Produce_Category_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_CATEGORY;
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
							unlink(UPLOADS_CATEGORY.$this->input->post('old_image'));  
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
					'fresh_produce_title' => $this->input->post('fresh_produce_title'),
					'fresh_produce_image'=>$imagename,
					'updated_at'   => date('Y-m-d H:i:s')
				);
				$where = array('fresh_category_id'=>$id);
				$update = $this->common->update($data,$where,'fresh_produce_category');

				if ($update)
				{
					log_activity("fresh_produce_category Updated [ID: $id]");

					set_alert('success', _l('_updated_successfully', 'Fresh Produce Category'));
					redirect('admin/fresh_produce_category');
				}
			}
			else
			{
				$cat = $this->freshproduce_category->get_one($id);
				$data['category'] = $cat[0];
				$data['content']  = $this->load->view('admin/fresh_produce_category/edit', $data, TRUE);
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
		$fresh_category_id = $this->input->post('fresh_category_id');
		$data = array(
			'is_delete'=>1,
			'updated_at'   => date('Y-m-d H:i:s')
		);
		$where = array('fresh_category_id'=>$fresh_category_id);
		$deleted     = $this->common->update($data,$where,'fresh_produce_category');

		if ($deleted)
		{
			log_activity("fresh_produce_category Deleted [ID: $fresh_category_id]");
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
			$wh = array('fresh_category_id'=>$id);
			$deleted = $this->common->update($data,$wh,'fresh_produce_category');
		}

		$ids = implode(',', $where);
		log_activity("fresh_produce_categories Deleted [IDs: $ids] ");

		echo 'true';
		
	}
}
