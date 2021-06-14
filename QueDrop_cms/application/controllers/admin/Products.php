<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Products extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('common_model', 'common');
		$this->load->model('product_model', 'products');
	}

	/**
	 * Loads the list of products.
	 */
	public function index()
	{
		$this->set_page_title(_l('products'));
		$data['products'] = $this->products->get_products();
		$data['content']  = $this->load->view('admin/products/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	/**
	 * Add new project
	 */
	public function add()
	{
		$this->set_page_title(_l('products').' | '._l('add'));

		if ($this->input->post('name'))
		{	
			if(!empty($_FILES['product_image']['name'])) 
			{
				$_FILES['file']['name']     = $_FILES['product_image']['name'];
				$_FILES['file']['type']     = $_FILES['product_image']['type'];
				$_FILES['file']['tmp_name'] = $_FILES['product_image']['tmp_name'];
				$_FILES['file']['error']     = $_FILES['product_image']['error'];
				$_FILES['file']['size']     = $_FILES['product_image']['size'];

				$temp = explode(".", $_FILES['product_image']['name']);
				$imagename = "Product_".round(microtime(true)) . '.' . end($temp);
				$config['upload_path'] = UPLOADS_PRODUCTS;
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
				'product_name'       => $this->input->post('name'),
				'product_description'=> $this->input->post('description'),
				'store_category_id'   => $this->input->post('category'),
				'product_price'		 => $this->input->post('price'),
				'product_image'       => $imagename,
				'is_active' => 1,
				'extra_fees'=>$this->input->post('extra_fees'),
				'need_extra_fees'=> $this->input->post('extra_fees') ? 1 :0,
				'is_testdata'=>1,
				'is_verified' => ($this->input->post('is_verified')) ? 1 : 0,
				'created_at'=>date('Y-m-d H:i:s'),
				'updated_at'=>date('Y-m-d H:i:s')
			);

			$insert = $this->common->insert($data,'product');

			if ($insert)
			{
				if(!empty($this->input->post('option_price'))){
					$count = count($this->input->post('option_price'));
					for($i=0;$i<$count;$i++){
						if(empty($this->input->post('option')[$i]) && $this->input->post('is_default')[$i]== 1){
							$option = 'Default';
						} else {
							$option = $this->input->post('option')[$i];
						}
						$data_options = array(
							'product_id'=>$insert,
							'option_name'=>$option,
							'price'=>$this->input->post('option_price')[$i],
							'is_default'=>$this->input->post('is_default')[$i],
							'is_testdata'=>1,
							'created_at'=>date('Y-m-d H:i:s')
						);
						$insert_option = $this->common->insert($data_options,'product_options');
					}		
				}

				if(!empty($this->input->post('addob_name'))){
					$new_count = count($this->input->post('addob_name'));
					for($j=0;$j<$new_count;$j++){
						$addon_data = array(
							'product_id'=>$insert,
							'addon_name'=>$this->input->post('addob_name')[$j],
							'addon_price'=>$this->input->post('addon_price')[$j],
							'is_testdata'=>1,
							'created_at'=>date('Y-m-d H:i:s')
						);
						$insert_addon = $this->common->insert($addon_data,'product_addons');
					}
				}

				set_alert('success', _l('_added_successfully', _l('product')));
				log_activity("New Product Created [ID:$insert]");
				redirect('admin/products');
			}
		}
		else
		{
			$data['store'] = $this->common->get_all('store');
			$data['content'] = $this->load->view('admin/products/create', $data, TRUE);
			$this->load->view('admin/layouts/index', $data);
		}
	}

	public function get_category(){
		if(!empty($this->input->post('id'))){
			$id = $this->input->post('id');
			$cat_list = $this->products->get_category($id);
			echo '<option>Select Food Category</option>';
			if(!empty($cat_list)) {
				foreach($cat_list as $cat){
					echo '<option value="'.$cat['store_category_id'].'">'.$cat['store_category_title'].'</option>';
				}
			} else {
				echo '<option>Store has no any category.</option>';
			}
		}
	}

	/**
	 * Updates the project record
	 *
	 * @param int  $id  The project id
	 */
	public function edit($id = '')
	{
		$this->set_page_title(_l('products').' | '._l('edit'));
		if ($id)
		{
			if ($this->input->post())
			{
				if(!empty($_FILES['product_image']['name']))
				{
					$_FILES['file']['name']     = $_FILES['product_image']['name'];
					$_FILES['file']['type']     = $_FILES['product_image']['type'];
					$_FILES['file']['tmp_name'] = $_FILES['product_image']['tmp_name'];
					$_FILES['file']['error']     = $_FILES['product_image']['error'];
					$_FILES['file']['size']     = $_FILES['product_image']['size'];
	
					$temp = explode(".", $_FILES['product_image']['name']);
					$imagename = "Product_".round(microtime(true)) . '.' . end($temp);
					$config['upload_path'] = UPLOADS_PRODUCTS;
					$config['allowed_types'] = 'gif|jpg|png|jpeg';
					$config['file_name'] = $imagename;
					$this->load->library('upload', $config);
					$this->upload->initialize($config);
					if($this->upload->do_upload('file')){
						$fileData = $this->upload->data();
						if(!empty($this->input->post('old_image')))
						{
							unlink(UPLOADS_PRODUCTS.$this->input->post('old_image'));  
						}
					}
					else
					{
							$error = array('error' => $this->upload->display_errors()); 
					}
				} else {
					$imagename = $this->input->post('old_image');
				}
				$data = array
					(
					'product_name'       => $this->input->post('name'),
					'product_description'=> $this->input->post('description'),
					'store_category_id'   => $this->input->post('category'),
					'product_price'		 => $this->input->post('price'),
					'product_image'       => $imagename,
					'is_active' => ($this->input->post('is_active')) ? 1 : 0,
					'need_extra_fees'=> $this->input->post('extra_fees') ? 1 :0,
					'is_testdata'=>1,
					'is_verified' => ($this->input->post('is_verified')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s')
				);
				$where = array('product_id'=>$id);
				$update = $this->common->update($data,$where,'product');

				if ($update)
				{

						if(!empty($this->input->post('option_price'))){
							$count = count($this->input->post('option_price'));
							for($i=0;$i<$count;$i++){
								if(empty($this->input->post('option')[$i]) && $this->input->post('is_default')[$i]== 1){
									$option = 'Default';
								} else {
									$option = $this->input->post('option')[$i];
								}
								$data_options = array(
									'product_id'=>$id,
									'option_name'=>$option,
									'price'=>$this->input->post('option_price')[$i],
									'is_default'=>$this->input->post('is_default')[$i],
									'is_testdata'=>1,
								); 
								if(!empty($this->input->post('id')[$i])){
									$data_options['updated_at']= date('Y-m-d H:i:s');
									$where_opt = array('option_id'=>$this->input->post('id')[$i]);
									$up_op = $this->common->update($data_options,$where_opt,'product_options');
								} else {
									$data_options['created_at']= date('Y-m-d H:i:s');
									$insert_option = $this->common->insert($data_options,'product_options');
								}
								
							}		
						}
					

					if(!empty($this->input->post('delete_option'))){
						$delete_val = $this->input->post('delete_option');
						$del = explode(",",$delete_val);
						foreach($del as $d){
							$d_array = array(
								'is_delete'=>1,
								'updated_at'=>date('Y-m-d H:i:s')
							);
							$wh_d = array('option_id'=>$d);
							$up_op = $this->common->update($d_array,$wh_d,'product_options');
						}
					}

					
					if(!empty($this->input->post('addob_name'))){
						$new_count = count($this->input->post('addob_name'));
						for($j=0;$j<$new_count;$j++){
							$addon_data = array(
								'product_id'=>$id,
								'addon_name'=>$this->input->post('addob_name')[$j],
								'addon_price'=>$this->input->post('addon_price')[$j],
								'is_testdata'=>1,
							);
							if(!empty($this->input->post('addon_id')[$j])){
								$addon_data['updated_at'] = date('Y-m-d H:i:s');
								$where_opt = array('addon_id'=>$this->input->post('addon_id')[$j]);
								$up_op = $this->common->update($addon_data,$where_opt,'product_addons');
							} else {
								$addon_data['created_at'] = date('Y-m-d H:i:s');
								$insert_addon = $this->common->insert($addon_data,'product_addons');
							}
							
						}
					}
					

					if(!empty($this->input->post('delete_addon'))){
						$delete_val = $this->input->post('delete_addon');
						$del = explode(",",$delete_val);
						foreach($del as $d){
							$d_array = array(
								'is_delete'=>1,
								'updated_at'=>date('Y-m-d H:i:s')
							);
							$wh_d = array('addon_id'=>$d);
							$up_op = $this->common->update($d_array,$wh_d,'product_addons');
						}
					}



					set_alert('success', _l('_updated_successfully', _l('product')));
					log_activity("Product Updated [ID:$id]");
					redirect('admin/products');
				}
			}
			else
			{
				$products = $this->products->get_one($id);
				if(!empty($products)){
					$category_id = $products[0]['store_category_id'];
					$get_store_id = $this->products->get_store_id($category_id);
					if(!empty($get_store_id)){
						$store_id = $get_store_id[0]['store_id'];
					}
				}
				$data['store_id'] = $store_id;
				$data['product'] = $products[0];
				$data['store_category'] = $this->products->get_category($store_id);
				$data['store'] = $this->common->get_all('store');
				$data['options'] = $this->products->get_options($id);
				$data['addons'] = $this->products->get_addons($id);
				$data['content'] = $this->load->view('admin/products/edit', $data, TRUE);
				$this->load->view('admin/layouts/index', $data);
			}
		}
		else
		{
			redirect('admin/products');
		}
	}

	public function view($id){
		$products = $this->products->get_one($id);
		if(!empty($products)){
			$category_id = $products[0]['store_category_id'];
			$get_store_id = $this->products->get_store_id($category_id);
			if(!empty($get_store_id)){
				$store_id = $get_store_id[0]['store_id'];
			}
		}
		$data['store_id'] = $store_id;
		$data['product'] = $products[0];
		$data['store_category'] = $this->products->get_category($store_id);
		$data['store'] = $this->common->get_all('store');
		$data['options'] = $this->products->get_options($id);
		$data['addons'] = $this->products->get_addons($id);
		$data['content'] = $this->load->view('admin/products/view', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);

	}

	public function verify_product($id){
		if ($this->input->post()){
			$data = array
				(
					'is_verified' => ($this->input->post('verify_product')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s')
				);
				$where = array('product_id'=>$id);
				$update = $this->common->update($data,$where,'product');
				if ($update)
				{
					set_alert('success', 'Verify Product Successfully');
					log_activity("User Updated [ID: $id]");
					redirect('admin/products');
				}
		}
	}

	/**
	 * Deletes the single project record
	 */
	public function delete()
	{
		$project_id = $this->input->post('product_id');
		$where = array('product_id'=>$project_id);
		$data = array(
			'is_delete'=>1,
			'updated_at'=>date('Y-m-d H:i:s')
		);
		$deleted    = $this->common->update($data,$where,'product');

		if ($deleted)
		{
			log_activity("Product Deleted");
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
				'updated_at'   => date('Y-m-d H:i:s')
			);
			$wh = array('product_id'=>$id);
			$deleted = $this->common->update($data,$wh,'product');
		}
		$ids = implode(',', $where);
		log_activity("Products Deleted");
		echo 'true';
		
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('is_active' => $this->input->post('is_active'),'updated_at'=>date('Y-m-d H:i:s'));
		$where = array(
			'product_id'=>$user_id,
		);
		$update = $this->common->update($data,$where,'product');

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
