<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('view_store'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/stores'); ?>"><?php _el('stores'); ?></a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">

	<!-- <form id="orderform"> -->
		<form id="store" action="<?php echo base_url('admin/stores/verify_store/').$store['store_id']; ?>" method="POST">
		<div class="row">
			<div class="col-md-6 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Store Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<span><b>Store Name: </b>  <?php echo $store['store_name'];?></span><br>
                                <span><b>Store Address:</b> <?php echo $store['store_address'];?></span><br>
                                <span><b>Latitude:</b> <?php echo $store['latitude'];?></span><br>
                                <span><b>Longitude:</b> <?php echo $store['longitude'];?></span><br>
								<span><b>Can Provide Service:</b><?php if($store['can_provide_service'] == 1){echo 'Yes';}else{echo 'No';}?></span><br>
                                <span><b>Service Category: </b><?php
                                    if(!empty($store['service_category_id'])){
                                        if(!empty($service_category)){
                                            foreach($service_category as $cat){
                                                if($cat['service_category_id'] == $store['service_category_id']){
                                                    echo $cat['service_category_name'];
                                                }
                                            }
                                        }
                                    }
                                ?></span><br>
							 </div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			<div class="col-md-6 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Supplier Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12"> 
                                <span><b>Name: </b>  <?php echo $users[0]['first_name']." ".$users[0]['last_name'];?></span><br>
                                <span><b>Address:</b> <?php echo $users[0]['address'];?></span><br>
                                <span><b> Email:</b> <?php echo $users[0]['email'];?></span><br>
                                <span><b>Phone No:</b> <?php echo $users[0]['phone_number'];?></span><br>
                             </div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			<?php if(!empty($store_banners)) { ?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Store Images</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
                            <div class="col-lg-3 col-sm-6">
                                    <?php if(!empty($store['store_logo'])) {?>
                                    <div class="thumbnail">
                                        <div class="thumb">
                                            <img src="<?php echo VIEW_STORES_LOGO.$store['store_logo'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
                                            <div class="caption-overflow">
                                                <span>
                                                    <a href="<?php echo VIEW_STORES_LOGO.$store['store_logo'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
                                                    <!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
                                                </span>
                                            </div>
                                        <div class="caption">
                                            <h6 class="no-margin">
                                                <a href="#" class="text-default">Store Logo</a> 
                                                <a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
                                            </h6>
                                        </div>
                                    </div>
                                    </div> <?php } else { echo "Store Logo not available"; } ?>
                                </div>
								<?php foreach($store_banners as $banners){
                                ?>
                                <div class="col-lg-3 col-sm-6">
                                    <?php if(!empty($banners['slider_image'])) {?>
                                    <div class="thumbnail">
                                        <div class="thumb">
                                            <img src="<?php echo VIEW_STORES_STORES_S.$banners['slider_image'];?>" alt="" style="height: 240px;">
                                            <div class="caption-overflow">
                                                <span>
                                                    <a href="<?php echo VIEW_STORES_STORES_S.$banners['slider_image'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
                                                    <!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
                                                </span>
                                            </div>
                                        <div class="caption">
                                            <h6 class="no-margin">
                                                <a href="#" class="text-default">Store Banner</a> 
                                                <a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
                                            </h6>
                                        </div>
                                    </div>
                                    </div> <?php } else { echo "Store Banner not available"; } ?>
                                </div>
                                <?php
                                }?>
                            </div>
						</div>
					</div>

				</div>
			</div>
			<?php } 
			if(!empty($store_schedule)) {
			?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Store Schedule</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                        <table id="schedule">
                                    <tr>
                                        <th>Weekday</th>
                                        <th>Opening Time</th>
                                        <th>Closing Time</th>
                                    </tr>
                            <?php
                                foreach($store_schedule as $schedule){
                                ?>
                                <tr>
                                    <td><?php echo $schedule['weekday']?></td>
                                    <td><?php echo $schedule['opening_time']?></td>
                                    <td><?php echo $schedule['closing_time']?></td>
                                </tr>
                                    
                                
                                <?php
                                }
                            ?>
                            </table>
						</div>

						<div class="panel-body">
						<div class="row">
							<div class="form-group">
								<label class="checkbox-inline checkbox-right">
									<input type="checkbox" class="styled" name="verify_store" id="verify_store" <?php if($store['is_verified'] == 1){echo "checked";}?>>Verify Store
								</label>
							</div>
						</div>
					</div>
					</div>
				</div>
			</div>
			<?php }?>
		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<button type="submit" class="btn btn-success verify_submit" name="submit"><?php _el('save'); ?></button>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
		<!-- <div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div> -->
	</form>
</div>
<!-- /Content area -->
<style>
#schedule {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#schedule td, #schedule th {
  border: 1px solid #ddd;
  padding: 8px;
}

#schedule tr:nth-child(even){background-color: #f2f2f2;}

#schedule tr:hover {background-color: #ddd;}

#schedule th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #26A69A;
  color: white;
}
</style>
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>

<script>
$(document).ready(function(){
	$(document).on('click','.verify_submit',function(){
		var is_verified = 0;
		var user_id = '<?php echo $store["user_id"];?>';
		var store_id = '<?php echo $store['store_id'] ?>';
		if($("#verify_store").is(":checked")){
			is_verified = 1;
		}
		var socket = io.connect('http://34.204.81.189:30080/'); 
		var data = {
				user_id : user_id,
				is_verified : is_verified
			};
			socket.emit('store_verification', data, function(callBack) {
				console.log(callBack);
			}) ; 
	});
});

</script>



