<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Payments extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('common_model', 'common');
		$this->load->model('payment_model', 'payments');
    }

    public function get_details(){
        $data['drivers'] = array();
        $data['store'] = array();
        if(!empty($this->input->post('datepicker')) && !empty($this->input->post('datepicker2'))) {
            $get_voucher_details = $this->payments->get_voucher($this->input->post('datepicker'),$this->input->post('datepicker2'));
            $get_data = $this->payments->get_orders($this->input->post('datepicker'),$this->input->post('datepicker2'));

            if(!empty($get_voucher_details)){
                foreach($get_voucher_details as $voucher){
                    $driver_ids[] = $voucher['user_id'];
                }
            }
            
            if(!empty($get_data)){
                foreach($get_data as $driver){
                    $driver_ids[] = $driver['user_id'];
                }
            }

            if(!empty($driver_ids)){
                $driver_id = array_unique($driver_ids); 
                if(!empty($driver_id)){
                    foreach($driver_id as $dr){
                        $driver_details[$dr] = $this->payments->get_driver_details($dr);
                    }
                    $data['drivers'] = $driver_details;
                }
            }
            

            $get_store_data = $this->payments->get_store_orders($this->input->post('datepicker'),$this->input->post('datepicker2'));
            if(!empty($get_store_data)){
                foreach($get_store_data as $store){
                    $store_ids[] = $store['store_id'];
                }
                $store_id = array_unique($store_ids);
                if(!empty($store_id)){
                    foreach($store_id as $dr){
                        $store_details[$dr] = $this->payments->get_store($dr);
                    }
                    $data['store'] = $store_details;
                    $data['drivers'] = $driver_details;
                }
            }
            $data['start_date'] = $this->input->post('datepicker');
            $data['end_date'] = $this->input->post('datepicker2');

            $get_or  = $this->load->view('admin/payments/driver', $data, TRUE);
            echo $get_or;
        }
    }

    public function view(){
        $data = array();
        $store_list = $this->common->get_all('store');
        if(!empty($store_list)){
            $data['store'] = $store_list;
        }
        $data['content']  = $this->load->view('admin/payments/view', $data, TRUE);
        $this->load->view('admin/layouts/index', $data);
    }

    public function driver_payments(){
        $driver_list = $this->payments->get_drivers();
        if(!empty($driver_list)){
            $data['drivers'] = $driver_list;
            $data['content']  = $this->load->view('admin/payments/driver', $data, TRUE);
		    $this->load->view('admin/layouts/index', $data);
        }
    }

    public function view_store($id){
        $start_date = $this->input->get('start_date');
        $end_date = $this->input->get('end_date');
        $get_week_pay = $this->payments->get_store_week_pay($id,$start_date,$end_date);
        if(!empty($get_week_pay)){
            $weekly_pay = array(
                'id'=>$get_week_pay[0]['weekly_payment_id'],
                'actual_amount_pay'=>$get_week_pay[0]['actual_amount_to_pay'],
                'comment'=>$get_week_pay[0]['comment'],
                'confirm_payment'=>$get_week_pay[0]['confirm_payment']
              );
              $data['confirm_details'] = $weekly_pay;
        } 
        $get_store_payment = $this->payments->get_store_payments($id,$start_date,$end_date);
        $store_details = $this->payments->get_store($id); 
        if(!empty($store_details)){
            $data['store'] = $store_details[0];
            $user_id = $store_details[0]['user_id'];
            $get_account_details = $this->payments->get_bank_details($user_id);  
            if(!empty($get_account_details)){
                $data['account_details'] = $get_account_details;
            }
        }
        if(!empty($get_store_payment)){
            $data['store_orders'] = $get_store_payment;
                foreach($get_store_payment as $store_data){ 
                    $get_order_details = $this->payments->get_order($store_data['order_id']);
                    if(!empty($get_order_details)){
                        $or_user_id = $get_order_details[0]['user_id'];
                    } 
                    $ch = curl_init();
                    curl_setopt($ch, CURLOPT_URL, 'http://clientapp.narola.online/pg/GoferApp/GoferAppService.php?Service=GetConfirmOrderDetail');
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                    curl_setopt($ch, CURLOPT_POST, 1);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, "{\n\"secret_key\" : \"FEinhS54sNUNNll0tjqNdzLskf3SPgUISZzp1vIZXzE=\",\n\"access_key\" : \"nousername\",\n\"user_id\" : ".$or_user_id.",\n\"order_id\" : ".$store_data['order_id']."\n}");

                    $headers = array();
                    $headers[] = 'Cache-Control: no-cache';
                    $headers[] = 'Postman-Token: 1fb5df4e-6a80-ad31-59d5-c6e887f8dd67';
                    $headers[] = 'User-Agent: iOS';
                    $headers[] = 'Content-Type: application/x-www-form-urlencoded';
                    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

                    $result = curl_exec($ch);  
                    $result_array = json_decode($result); 
                    if (curl_errno($ch)) {
                        echo 'Error:' . curl_error($ch);
                    } 

                    if(!empty($result_array)){
                        $data['order_data'][$store_data['order_id']] = $result_array;
                    }
                
            } 
        }
        $data['start_date'] = $start_date;
        $data['end_date'] = $end_date;
        $data['content']  = $this->load->view('admin/payments/view_store', $data, TRUE);
        $this->load->view('admin/layouts/index', $data);
    }

    public function view_driver($id){
        $start_date = $this->input->get('start_date');
        $end_date = $this->input->get('end_date');
       
        $get_pay_details = $this->payments->get_pay_deivers($id,$start_date,$end_date);
        $get_voucher_details = $this->payments->get_voucher_details($id,$start_date,$end_date);
        if(!empty($get_pay_details)){ 
            $weekly_pay = array(
              'id'=>$get_pay_details[0]['weekly_payment_id'],
              'actual_amount_pay'=>$get_pay_details[0]['actual_amount_to_pay'],
              'comment'=>$get_pay_details[0]['comment'],
              'confirm_payment'=>$get_pay_details[0]['confirm_payment']
            );
            $data['confirm_details'] = $weekly_pay;
        }
        $get_store_payment = $this->payments->get_driver_payments($id,$start_date,$end_date);
        $dynamic_fee_per = $this->payments->get_percentage();
        $data['percentage'] = $dynamic_fee_per[0]['shopping_fee_percentage'];
        if(!empty($get_store_payment)){
            foreach($get_store_payment as $pay){
               $order_id = $pay['order_id']; 
               $get_order = $this->payments->get_order($order_id);
               $user_id = $get_order[0]['user_id'];
               $tip = $get_order[0]['tip'];
               $ch = curl_init();

			curl_setopt($ch, CURLOPT_URL, 'http://clientapp.narola.online/pg/GoferApp/GoferAppService.php?Service=GetConfirmOrderDetail');
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_POST, 1);
			curl_setopt($ch, CURLOPT_POSTFIELDS, "{\n\"secret_key\" : \"FEinhS54sNUNNll0tjqNdzLskf3SPgUISZzp1vIZXzE=\",\n\"access_key\" : \"nousername\",\n\"user_id\" : ".$user_id.",\n\"order_id\" : ".$order_id."\n}");

			$headers = array();
			$headers[] = 'Cache-Control: no-cache';
			$headers[] = 'Postman-Token: 1fb5df4e-6a80-ad31-59d5-c6e887f8dd67';
			$headers[] = 'User-Agent: iOS';
			$headers[] = 'Content-Type: application/x-www-form-urlencoded';
			curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

			$result = curl_exec($ch);  
			$result_array = json_decode($result); 
			if (curl_errno($ch)) {
				echo 'Error:' . curl_error($ch);
			} 

			if(!empty($result_array)){
                $data_order[] = array(
                   'order_id'=>$order_id,
                   'order_date'=>$pay['created_at'],
                   'tip'=>$tip,
                   'driver_detail'=>$result_array->data->order_billing_details->driver_detail,
                   'billing_detail'=>$result_array->data->order_billing_details->billing_detail,
                );
			  }
            }
        }   
        $data['id'] = $id;
        if(!empty($data_order)){
            $data['order'] = $data_order;
        }
        
        $store_details = $this->payments->get_driver_details($id);
        $data['driver_details'] = $store_details;
        if(!empty($store_details)){
            $user_id = $store_details[0]['user_id'];
            $get_account_details = $this->payments->get_bank_details($user_id);  
            if(!empty($get_account_details)){
                $data['account_details'] = $get_account_details;
            }
        }
        
        if(!empty($get_store_payment)){
            $data['driver_orders'] = $get_store_payment;
        }
        // if(!empty($get_pay_details)){
        //    foreach($get_pay_details as $pay){
        //        $created_date = date('Y-m-d', strtotime($pay['created_at']));
        //        if($pay['confirm_payment'] == 1 && $created_date == date('Y-m-d')){  
        //              $data['order'] = array();
        //        }
        //    } 
        // }
        $data['voucher'] = $get_voucher_details;
        $data['start_date'] = $start_date;
        $data['end_date'] = $end_date;
        $data['content']  = $this->load->view('admin/payments/view_driver', $data, TRUE);
        $this->load->view('admin/layouts/index', $data);
    }

    public function confirm_store($id){
        if(!empty($this->input->post('id'))){
            if(!empty($this->input->post('is_store'))){
                $is_store = 1;
            } else {$is_store = 0;}
            if(!empty($this->input->post('is_driver'))){
                $is_driver = 1;
            } else { $is_driver = 0;}
            $array = array(
                'order_ids'=>$this->input->post('order_ids'),
                'actual_amount_to_pay'=>$this->input->post('actual_amount'),
                'comment'=>$this->input->post('comment'),
                'confirm_payment'=>($this->input->post('con_dri')) ? 1 : 0,
                'is_store'=>$is_store,
                'is_driver'=>$is_driver,
                'driver_store_id'=>$this->input->post('id'),
                'week_start_date'=>$this->input->post('start_date'),
                'week_end_date'=>$this->input->post('end_date'),
                'is_testdata'=>1
            );
            if(!empty($this->input->post('week_id'))) {
                $array['weekly_payment_id'] = $this->input->post('week_id');
                $array['updated_at']= date('Y-m-d H:i:s');
                $update = $this->payments->update_payment($array);
            } else {
                $array['created_at']= date('Y-m-d H:i:s');
                $update = $this->payments->insert_payment($array);
            }
            echo $update;
            if ($update)
			{
				set_alert('success', 'Payment Confirmed Successfully');
				// redirect('admin/payments/view');
			}
        }
    }

    public function confirm_driver($id){
        if(!empty($this->input->post('actual_amount'))){
            if(!empty($this->input->post('is_store'))){
                $is_store = 1;
            } else {$is_store = 0;}
            if(!empty($this->input->post('is_driver'))){
                $is_driver = 1;
            } else { $is_driver = 0;}
            $array = array(
                'order_ids'=>($this->input->post('order_ids')) ? $this->input->post('order_ids') : '',
                'total_delivery_charge'=>($this->input->post('total_delivery_charge')) ? $this->input->post('total_delivery_charge') : 0,
                'total_tip'=>($this->input->post('total_tip')) ? $this->input->post('total_tip') : 0,
                'total_shopping_fees'=>($this->input->post('total_shopping_fee')) ? $this->input->post('total_shopping_fee') : 0,
                'actual_amount_to_pay'=>$this->input->post('actual_amount'),
                'comment'=>$this->input->post('comment'),
                'confirm_payment'=>($this->input->post('con_dri')) ? 1 : 0,
                'is_store'=>$is_store,
                'is_driver'=>$is_driver,
                'driver_store_id'=>$this->input->post('id'),
                'week_start_date'=>$this->input->post('start_date'),
                'week_end_date'=>$this->input->post('end_date'),
                'is_testdata'=>1
                
            );
            if(!empty($this->input->post('week_id'))) {
                $array['weekly_payment_id'] = $this->input->post('week_id');
                $array['updated_at']= date('Y-m-d H:i:s');
                $update = $this->payments->update_payment($array);
            } else {
                $array['created_at']= date('Y-m-d H:i:s');
                $update = $this->payments->insert_payment($array);
            }

            if(!empty($this->input->post('voucher_ids'))){
                $count = count($this->input->post('voucher_ids'));
                for($i=0;$i<$count;$i++){
                    $voucher_data = array(
                        'voucher_id'=>$this->input->post('voucher_ids')[$i],
                        'is_paid'=>($this->input->post('con_dri')) ? 1 : 0,
                        'updated_at'=>date('Y-m-d H:i:s')
                    );
                    $voucher_update = $this->payments->update_voucher($voucher_data);
                }
            }
            echo $update;
            if ($update)
			{
				set_alert('success', 'Payment Confirmed Successfully');
				// redirect('admin/payments/view');
			}
        }
    }

}