<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">View Driver Payments</span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/payments/view'); ?>">Driver Payments</a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="drivr" action="<?php echo base_url('admin/payments/confirm_driver/').$id; ?>" method="POST">
		<div class="row">
			<input type="hidden" name="id" value="<?php echo $id;?>">
			<input type="hidden" name="is_driver" value="1">
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Driver Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<?php 
                                        if(!empty($driver_details)){ 
                                        ?>
                                        <div class="col-md-12">
										<div>
											<span><b>Name:</b> <?php echo $driver_details[0]['first_name']." ".$driver_details[0]['first_name'];?></span><br>
											<span><b>Address:</b> <?php echo $driver_details[0]['address'];?></span><br>
                                            <span><b>Email:</b> <?php echo $driver_details[0]['email'];?></span><br>
                                            <span><b>Phone No:</b> <?php echo $driver_details[0]['phone_number'];?></span><br>
										</div>
									</div>
                                        <?php
                                        }
                                    ?>
						</div>
					</div>
				</div>
			</div>
            <?php 
            $total_registered = 0;
            $total_voucher = 0;
            if(!empty($order)){?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Order Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                        <?php 
                        if(!empty($order)){
                            ?>
                            <span><b>Registered Store</b></span><br>
                            <table id="account_details">
                                            <tr>
                                                <th>Order Id</th>
                                                <th>Order Amount</th>
                                                <th>Delivery Charge</th>
                                                <th>Tip</th>
                                                <th>Shopping Fee</th>
                                                <th>Order Date</th>
                                            </tr>
                                    <?php $i = 0;
                                    $len = count($order);
                                    foreach($order as $order_details){
                                        $order_ids[] =  $order_details['order_id'];
                                        if(!empty($order_details['billing_detail']->registered_stores)) {
                                            $i++;
                                            $del_ch[] = $order_details['billing_detail']->delivery_charge;
                                            $total_tip[] = $order_details['tip'];
                                            $total_shopping_fee[] = $order_details['billing_detail']->shopping_fee;
                                            $deliver_total[] = ($order_details['billing_detail']->shopping_fee*$percentage)/100;
                                        ?>
                                        <tr>
                                            <td><?php echo "#".$order_details['order_id'];?></td>
                                            <td><?php echo "$".$order_details['billing_detail']->total_pay;?></td>
                                            <td><?php echo "$".$order_details['billing_detail']->delivery_charge;?></td>
                                            <td><?php echo "$".$order_details['tip'];?></td>
                                            <td><?php echo "$".($order_details['billing_detail']->shopping_fee*$percentage)/100;?></td>
                                            <td><?php echo date('m-d-Y', strtotime($order_details['order_date']));?></td>
                                        </tr>
                                        <?php
                                        }
                                    }
                                    ?>
                                    <tr>
                                        <td>Total Order : <b><?php echo $i;?></b></td>
                                        <td></td>
                                        <td>Total Delivery Charg: <b><?php echo "$".array_sum($del_ch);?></b></td>
                                        <td>Total Tip: <b><?php echo "$".array_sum($total_tip);?></b></td>
                                        <td>Total Shopping Fee: <b><?php echo "$".array_sum($deliver_total);?></b></td>
                                        <td></td>
                                    </tr>
                                    <?php
                                $order_ids = implode(',',$order_ids);   
                                $total_registered =  array_sum($del_ch) + array_sum($total_tip) +  array_sum($deliver_total);
                                ?>

                                </table><br>
                                <input type="hidden" name="order_ids" value="<?php echo $order_ids;?>">
                            <?php
                                } else {
                                ?>
                                <span><b>Order Details not available</b></span>
                                <?php
                                } ?>
                        
						</div>
                        <?php if(!empty($del_ch)) {
                        ?><input type="hidden" name="total_delivery_charge" value="<?php echo array_sum($del_ch);?>"><?php
                        } 
                        if(!empty($total_tip)){
                        ?><input type="hidden" name="total_tip" value="<?php echo array_sum($total_tip);?>"><?php
                        }
                        if(!empty($deliver_total)){
                        ?><input type="hidden" name="total_shopping_fee" value="<?php echo array_sum($deliver_total);?>"><?php
                        }
                        ?>
                    </div>
				</div>
			</div>
            <?php }?>
            <?php if(!empty($voucher)) { ?>
            <div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Voucher Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                        <?php
                        if(!empty($voucher)) {
								?>
                        <div class="col-md-12">
                            <div>
                                <?php if(!empty($voucher)){
                                    ?>
                                        <table id="account_details">
                                            <tr>
                                                <th>Sn.</th>
                                                <th>Amount</th>
                                                <th>Date</th>
                                            </tr>
                                    <?php $i=0;
                                    foreach($voucher as $account){
                                        $i++;
                                        $voucher_amt[] = $account['amount'];
                                        $voucher_ids[] = $account['voucher_id'];
                                    ?>
                                    <tr>
                                        <td><?php echo $i;?></td>
                                        <td><?php echo "$".$account['amount'];?></td>
                                        <td><?php echo date('m-d-Y', strtotime($account['created_at']));?></td>
                                    </tr>
                                    <?php
                                    }
                                    ?>
                                    <tr>
                                        <td>Total Voucher : <b><?php echo count($voucher);?></b></td>
                                        <td>Total Voucher Amount : <b><?php echo "$".array_sum($voucher_amt);?></b></td>
                                        <td></td>
                                    </tr>
                                    <?php
                                }
                                $total_voucher = array_sum($voucher_amt);
                                $v_ids = implode(',',$voucher_ids);
                                ?>
                                </table>
                            </div>
                        </div>
                        <input type="hidden" name="voucher_ids" value="<?php echo $v_ids;?>">
                                
                        <?php } else {
                            ?>
                            <span><b>Voucher Details not available</b></span>
                            <?php
                        }?>
						</div>
					</div>
				</div>
			</div>
            <?php } ?>

            <?php if(!empty($account_details)) {?>
            <div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Bank Account Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                        <?php
                        if(!empty($account_details)) {
								?>
                        <div class="col-md-12">
                            <div>
                                <?php if(!empty($account_details)){
                                    ?>
                                        <table id="account_details">
                                            <tr>
                                                <th>Bank Name</th>
                                                <th>Account Number</th>
                                                <th>IFSC Code</th>
                                                <th>Account Type</th>
                                            </tr>
                                    <?php
                                    foreach($account_details as $account){
                                        $account_number = openssl_decrypt($account['account_number'],"AES-128-ECB",'3e87547b9029d3f35fc06b45fee93ebb');
                                        $ifsc_code = openssl_decrypt($account['ifsc_code'],"AES-128-ECB",'3e87547b9029d3f35fc06b45fee93ebb');
                                    ?>
                                    <tr>
                                        <td><?php echo $account['bank_name'];?></td>
                                        <td><?php echo $account_number;?></td>
                                        <td><?php echo $ifsc_code;?></td>
                                        <td><?php echo $account['account_type'];?></td>
                                    </tr>
                                    <?php
                                    }
                                }?>
                                </table>
                            </div>
                        </div>
                                
                        <?php } else {
                            ?>
                            <span><b>Bank Account Details not available</b></span>
                            <?php
                        }?>
						</div>
					</div>
				</div>
			</div>
            <?php } ?>
            <?php if(!empty($order) || !empty($voucher)){ ?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Confirm Payment</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                                <span class="pay_class"><b style="width:20%;">Total Driver Amount : </b><h6 style="margin-top:0%;"><?php echo "$".($total_registered+$total_voucher);?></h6></span>
                                <?php
                                 if (!empty($start_date)) {
                                    ?><input type="hidden" name="start_date" value="<?php echo date('Y-m-d', strtotime($start_date));?>"><?php
                                    } 
                                    if(!empty($end_date)) {
                                    ?><input type="hidden" name="end_date" value="<?php echo date('Y-m-d', strtotime($end_date));?>"><?php
                                    }
                                ?>
								<span class="pay_class"><b class="ti_cl">Actual Amount to Pay :</b>
                                <input type="text" name="actual_amount" id="ac_amount" class="form-control" placeholder="Ex:200" value="<?php if(!empty($confirm_details['actual_amount_pay'])){echo $confirm_details['actual_amount_pay'];}?>"></span><br>
								<span class="pay_class"><b class="ti_cl">Add Comment :</b><input type="text" name="comment" placeholder="Comment" class="form-control" value="<?php if(!empty($confirm_details['comment'])){echo $confirm_details['comment'];}?>"></span><br>
								<span class="pay_class"><b class="ti_cl" style="width:20%;">Confirm Payment to Store : </b><input type="checkbox" name="con_dri" class="styled" id="confirm_driver_pay" <?php if(!empty($confirm_details)){
                                    if($confirm_details['confirm_payment'] == 1){
                                        echo "checked";
                                    }
                                }?>></span><br>
                                <?php if(!empty($confirm_details)){
                                    ?>
                                    <input type="hidden" name="week_id" value="<?php echo $confirm_details['id'];?>">
                                    <?php
                                }?>
						</div>
					</div>
				</div>
			</div>
            <?php } ?>

		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<?php if(!empty($order) || !empty($voucher)){ ?><button type="submit" class="btn btn-success verify_submit" name="submit"><?php _el('save'); ?></button><?php }?>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<style>
.ti_cl{width:25%;}
.pay_class{
	display: inline-flex;
    width: 100%;
	margin-top: 1%;
}
#account_details {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#account_details td, #account_details th {
  border: 1px solid #ddd;
  padding: 8px;
}

#account_details tr:nth-child(even){background-color: #f2f2f2;}

#account_details tr:hover {background-color: #ddd;}

#account_details th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #26A69A;
  color: white;
}
</style>
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>
<script>


$("#drivr").submit(function(e) {
    if($("#ac_amount").val() == ''){
        jGrowlAlert("Actual Payment amount is required", 'danger');
        return false;
    }
e.preventDefault(); // avoid to execute the actual submit of the form.

var form = $(this);
var url = form.attr('action');
$.ajax({
       type: "POST",
       url: url,
       data: form.serialize(), // serializes the form's elements.
       success: function(data)
       {
            if($("#confirm_driver_pay").is(":checked")){
                var socket = io.connect('http://34.204.81.189:30080/'); 
                var data = {
                    driver_id : '<?php echo $id;?>',
                    is_driver : 1,
                    store_id : 0,
                    store_owner_id : 0,
                    weekly_payment_id : data,
                    week_start_date : '<?php echo date('Y-m-d', strtotime($start_date));?>',
                    week_end_date : '<?php echo date('Y-m-d', strtotime($end_date));?>'
                };
                socket.emit('confirm_weekly_payment', data, function(callBack) {
                    console.log(callBack);
                }) ; 
            }
            // show response from the php script.
            jGrowlAlert("Payment Confirmed Successfully", 'success');
            setTimeout(function(){ window.location.href = '<?php echo base_url();?>admin/payments/view'; }, 1000);
       }
     });
});

</script>




