<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Offers extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();

		$this->load->model('offer_model', 'offers');
		$this->load->model('role_model', 'roles');
		$this->load->model('common_model', 'common');
	}

	/**
	 * Loads the list of offers.
	 */
	public function index()
	{
		$this->set_page_title(_l('offers'));
		$data['offers'] = $this->offers->get_offers();
		$data['roles'] = $this->roles->get_all();
		$data['content'] = $this->load->view('admin/offers/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	/**
	 * Add new user
	 */
	public function add()
	{
		$this->set_page_title(_l('offers').' | '._l('add'));

		if ($this->input->post())
		{
			$data = array
			(
				'offer_type'=>$this->input->post('offer_type'),
				'offer_on'=>$this->input->post('offer_on'),
				'offer_range'=>$this->input->post('offer_range'),
				'discount_percentage'=>$this->input->post('discount_percentage'),
				'offer_description'=>$this->input->post('offer_description'),
				'start_date'=>$this->input->post('start_date'),
				'expiration_date'=>$this->input->post('expiration_date'),
				'is_active' => 1,
				'is_testdata'=>1,
				'created_at'=>date('Y-m-d H:i:s')
			);

			if(!empty($this->input->post('store_id'))) {
				$data['store_id'] = $this->input->post('store_id');
			 } 
			 
			 if(!empty($this->input->post('coupon_code'))) {
				$data['coupon_code'] = $this->input->post('coupon_code');
 			}

			$insert = $this->common->insert($data,'admin_offers');

			log_activity("New Offer Created [ID: $insert]");

			if ($insert)
			{
				set_alert('success', _l('_added_successfully', _l('offers')));
				redirect('admin/offers');
			}
		}
		else
		{
			$data['roles']   = $this->roles->get_all();
			$data['store'] = $this->common->get_all('store');
			$data['content'] = $this->load->view('admin/offers/create', $data, TRUE);
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
		$this->set_page_title(_l('offers').' | '._l('edit'));

		if ($id)
		{
			if ($this->input->post())
			{
				$data = array
				(
					'offer_type'=>$this->input->post('offer_type'),
					'offer_on'=>$this->input->post('offer_on'),
					'offer_range'=>$this->input->post('offer_range'),
					'discount_percentage'=>$this->input->post('discount_percentage'),
					'offer_description'=>$this->input->post('offer_description'),
					'start_date'=>$this->input->post('start_date'),
					'expiration_date'=>$this->input->post('expiration_date'),
					'is_active' => ($this->input->post('is_active')) ? 1 : 0,
					'updated_at'=>date('Y-m-d H:i:s')
				);

				if(!empty($this->input->post('store_id'))) {
					$data['store_id'] = $this->input->post('store_id');
				} 
				
				if(!empty($this->input->post('coupon_code'))) {
					$data['coupon_code'] = $this->input->post('coupon_code');
				}
					
				
				$where = array('admin_offer_id'=>$id);
				$update = $this->common->update($data,$where,'admin_offers');

				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('offers')));
					log_activity("Offer Updated [ID: $id]");
					redirect('admin/offers');
				}
            } else {
				$order = $this->offers->get_order($id);
				if(empty($order)) {
					$offers = $this->offers->get_one($id);
					$data['offer']  = $offers[0];
					$data['store'] = $this->common->get_all('store');
					$data['roles'] = $this->roles->get_all();

					$data['content'] = $this->load->view('admin/offers/edit', $data, TRUE);
					$this->load->view('admin/layouts/index', $data);
				} else {
					set_alert('danger', 'This offer is in use. So you can not update this !');
					redirect('admin/offers');
				}
			}
		}
		else
		{
			redirect('admin/offers');
		}
	}

	/**
	 * Toggles the user status to Active or Inactive
	 */
	public function update_status()
	{
		$user_id = $this->input->post('user_id');
		$data    = array('is_active' => $this->input->post('is_active'),'updated_at'=>date('Y-m-d H:i:s'));
		$where = array('admin_offer_id'=>$user_id);
		$update = $this->common->update($data,$where,'admin_offers');
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
		$order = $this->offers->get_order($user_id);
		if(empty($order)) {
			$data    = array('is_delete' => 1,'updated_at'=>date('Y-m-d H:i:s'));
			$where = array('admin_offer_id'=>$user_id);
			$update = $this->common->update($data,$where,'admin_offers');

			if ($update)
			{
				log_activity("Deal Deleted [ID: $user_id]");
				echo 'true';
			}
			else
			{
				echo 'false';
			}
		} else {
			set_alert('danger', 'This offer is in use. So you can not update this !');
			redirect('admin/offers');
		}
		
	}

	/**
	 * Deletes multiple user records
	 */
	public function delete_selected()
	{
		$where   = $this->input->post('ids');
		$status = 'true';
		foreach($where as $id) {
			$order = $this->offers->get_order($id);
			if(empty($order)) {
				$data    = array('is_delete' => 1,'updated_at'=>date('Y-m-d H:i:s'));
				$wh = array('admin_offer_id'=>$id);
				$update = $this->common->update($data,$wh,'admin_offers');
			} else {
				$status = 'false';
			}
		}
		$ids = implode(',', $where);
		log_activity("offers Deleted [IDs: $ids]");
		echo $status;
		
	}

	public function get_selected(){
		if(!empty($this->input->post('val'))) {
			$where = array($this->input->post('id') =>$this->input->post('val')); print_r($where) ;
			$data = $this->offers->get_selected($where,$this->input->post('table_name'));
			echo "<option val='' selected>Please Select any one</option>";
			if(!empty($data)) {
				foreach($data as $id) { 
				  if($this->input->post('table_name') == 'store_food_category') {
					?><option value="<?php echo $id['store_category_id'];?>"><?php echo $id['store_category_title'];?></option><?php
				  } else {
					?><option value="<?php echo $id['product_id'];?>"><?php echo $id['product_name'];?></option><?php 
				  }
				}
			}
		}
	}
}
