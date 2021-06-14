<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">View Product</span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/products'); ?>"><?php _el('products'); ?></a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="drivr" action="<?php echo base_url('admin/products/verify_product/').$product['product_id']; ?>" method="POST">
		<div class="row">
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Product Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<?php if(!empty($product)) {	?>
									<div class="col-md-12">
                                    <div class="col-lg-3 col-sm-6">
                                    <?php if(!empty($product['product_image'])) {?>
                                    <div class="thumbnail">
                                        <div class="thumb">
                                            <img src="<?php echo VIEW_PRODUCTS.$product['product_image'];?>" alt="" style="height: 240px;">
                                            <div class="caption-overflow">
                                                <span>
                                                    <a href="<?php echo VIEW_PRODUCTS.$product['product_image'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
                                                    <!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
                                                </span>
                                            </div>
                                        <div class="caption">
                                            <h6 class="no-margin">
                                                <a href="#" class="text-default">Product Image</a> 
                                                <a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
                                            </h6>
                                        </div>
                                    </div>
                                    </div> <?php } else { echo "Product Image Not Available"; } ?>
                                </div>
										<div>
											<span><b>Product Name:</b> <?php echo $product['product_name'];?></span><br>
											<span><b>Product Description:</b> <?php echo $product['product_description'];?></span><br>
                                            <?php if(!empty($store_category)){
                                                $category_name = $store_category[0]['store_category_title'];
                                            ?>
                                            <span><b>Product Category:</b> <?php echo $category_name;?></span><br>
                                            <?php
                                            }?>
											<span><b>Product Extra Fees:</b> <?php echo $product['extra_fees'];?></span><br>
                                            <?php if(!empty($options)){
                                            ?>
                                            <span><b>Product Options : </b></span><br>
                                            <?php $i=0;
                                            foreach($options as $op){ $i++;
                                            ?>
                                            <span><?php echo $i;?>. &nbsp;&nbsp;&nbsp;<?php echo $op['option_name'];?> &nbsp;&nbsp;&nbsp;<b><?php echo "$".$op['price'];?></b></span><br>
                                            <?php
                                            }?>
                                            <?php
                                            }
                                            if(!empty($addons)){
                                            ?>
                                            <span><b>Product Addons : </b></span><br>
                                            <?php
                                            $j =0;
                                            foreach($addons as $add){ $j++;
                                            ?>
                                            <span><?php echo $j;?>. &nbsp;&nbsp;&nbsp;<?php echo $add['addon_name'];?> &nbsp;&nbsp;&nbsp;<b><?php echo "$".$add['addon_price'];?></b></span><br>
                                            <?php
                                            }
                                            }
                                            ?>
                                            <?php 
                                                if(!empty($store)) {
                                                    foreach($store as $cat) {
                                                    ?>
                                                    <?php if($cat['store_id'] == $store_id) {
                                                    ?>
                                                    <span><b>Store Name : </b><?php echo $cat['store_name'];?></span><br>
                                                    <span><b>Store Address : </b><?php echo $cat['store_address'];?></span><br>
                                                    <?php
                                                    } ?>
                                                    <?php
                                                    }
                                                }
                                            ?>
                                            
										</div>
									</div>
											
									<?php }?>
						</div>
					</div>
				</div>
			</div>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Verify Product</strong> 
                                    <?php 
                                        if(!empty($store)) {
											foreach($store as $cat) {
											?>
											<?php if($cat['store_id'] == $store_id) {
                                                $store_owner_id = $cat['user_id'];
                                            } ?>
											<?php
											}
										}
                                    ?>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="form-group">
								<label class="checkbox-inline checkbox-right">
									<input type="checkbox" class="styled" name="verify_product" id="verify_product" <?php if($product['is_verified'] == 1){echo "checked";}?>>Verify Product
								</label>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<button type="submit" class="btn btn-success verify_submit" name="submit"><?php _el('save'); ?></button>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>

<script>
$(document).ready(function(){
	$(document).on('click','.verify_submit',function(){
		var is_product_verified = 0;
		if($("#verify_product").is(":checked")){
			is_product_verified = 1;
		}
		var socket = io.connect('http://34.204.81.189:30080/'); 
		var data = {
				product_id : '<?php echo $product['product_id'];?>',
				is_verified : is_product_verified,
                store_id:'<?php echo $store_id;?>',
                store_owner_id:'<?php echo $store_owner_id;?>',
                product_name:'<?php echo $product['product_name'];?>'
			};
			socket.emit('product_verification', data, function(callBack) {
				console.log(callBack);
            }) ; 
	});
});

</script>




